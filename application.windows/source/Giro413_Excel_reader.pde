import ddf.minim.*;
import de.bezier.data.*;
import javax.swing.*; 

Minim minim;
WaveformRenderer waveform;
XlsReader reader;
PFont font;
AlarmWindow alarmWindow;

//Variables for Minim
AudioPlayer[] team;
AudioPlayer alarm_sound;
int[] team_player;
int[] team_isPlaying;
int[] team_score;

//Variables keypad input
int temp1 = -1;
int temp2 = -1;

//Variables for setup
int numberOfTeams;
int numberOfEntries;
int alarmInterval = 15000;
Boolean useAlarm = null;

int progress = 0;
boolean setupIsComplete = false;
boolean loadingIsComplete = false;

//Variables for XlsReader
int pos = -1;
int max = -1;

int current_cell;
int current_song;

int last_song;
int last_check;

int check_interval = 1000; //determines how often the program should test whether there is a new team leading.

//Variables for timer
int alarmStartTime = 0;
int alarmEndTime = 0;
int hours_int;
int minutes_int;
int seconds_int;

int width = 500;
int height = 300;

public void settings() {
  size(width, height);
}

void setup(){
  frameRate(30);
  font = createFont("Arial",22);
  textFont(font);
  surface.setResizable(true);
}

void draw(){
  background(255);
  if(!setupIsComplete) {
    switch(progress) {
      case 0:
        setNumberOfTeams();
        break;
      case 1:
        setNumberOfEntries();
        break;
      case 2:
        setUseAlarm();
        break;
      case 3:
        setAlarmInterval();
        break;
      case 4:
        finishSetup();
        break;
    }
  }
  if(setupIsComplete && !loadingIsComplete) {
    text("Setup is complete", 40, 75);
    text("Loading program", 40, 100);
    loadProgram();
  }
  if(setupIsComplete && loadingIsComplete) {
    height = 200;
    surface.setSize(width, height);
    background(50);
    // see waveform.pde for an explanation of how this works
    waveform.draw();
    
    if(useAlarm && alarmWindow.playAlarm()) {
      if(!alarm_sound.isPlaying()) {
        startAlarm(true);
      } else {
        startAlarm(false);
      }
      return;
    }
    
    if (millis() - last_check > check_interval) {
      last_check = millis();
      println("Calling checkExcel");
      checkExcel();
    }
  }
}

void keyPressed(){
  int numPressed = Character.getNumericValue(key);
  println(numPressed);
  if(numPressed == -1) {
    saveInput();
  } else {
    getInput(numPressed);
  }
}

void getInput(int numPressed) {
  if(numPressed > -1 && numPressed <= 9) {
    if(temp1 != -1 && temp2 != -1) {
      temp1 = numPressed;
      temp2 = -1;
    } else if(temp1 == -1) {
      temp1 = numPressed;
    } else {
      temp2 = numPressed;
    }
  }
  
  if(numPressed == 34) {
    if(progress == 2) {
      useAlarm = true;
    }
    if(progress == 4) {
      setupIsComplete = true;
    }
  }
  
  if(numPressed == 23) {
    if(progress == 2) {
      useAlarm = false;
    }
    if(progress == 4) {
      temp1 = -1;
      temp2 = -1;
      numberOfTeams = 0;
      numberOfEntries = 0;
      alarmInterval = 0;
      useAlarm = null;

      progress = 0;
    }
  }
}

void saveInput() {
  println("Progress: " + progress);
  if(temp1 == -1 && temp2 == -1 && progress != 2) return;
  
  switch(progress) {
    case 0: //set number of teams
      if(temp1 == 1 && temp2 == -1) break;
      if(temp2 == -1 && temp1 > 1) {
        numberOfTeams = temp1;
      } else {
        numberOfTeams = (temp1 * 10 + temp2);
      }  
      temp1 = -1;
      temp2 = -1;
      
      progress++;
      break;
      
    case 1: //set number of entries
      if(temp2 == -1 && temp1 > 0) {
        numberOfEntries = temp1;
      } else {
        numberOfEntries = (temp1 * 10 + temp2);
      }
      temp1 = -1;
      temp2 = -1;
      
      progress++;
      break;  
      
    case 2: //set alarm
      println("Case use alarms");
      if(useAlarm != null) {
        temp1 = -1;
        temp2 = -1;
        if(useAlarm == false) {
          progress = progress + 2;
        } else if(useAlarm == true) {
          progress++;
        }
      }
      break;
    
    case 3: //set alarm interval
      if(temp2 == -1 && temp1 >= 1) {
        alarmInterval = temp1 * 60 * 1000;
      } else {
        alarmInterval = (temp1 * 10 * 60 * 1000 + temp2 * 60 * 1000);
      }
      temp1 = -1;
      temp2 = -1;
      
      progress++;
      break;
  }
}

void displayStatus() {
  fill(169,169,169);
  text("Number of teams: " + numberOfTeams, 20, 50);
  text("Number of entries: " + numberOfEntries, 20, 70);
  text("Alarm enabled: " + useAlarm, 20, 90);
  text("Alarm interval: " + alarmInterval/60/1000 + " min", 20, 110);
  fill(0);
}

void setNumberOfTeams() {
  displayStatus();
  
  text("Enter number of teams,", 20, 150);
  text("between 2 and 99.", 20, 175);
  text("Press enter when done", 20, 220);
  
  if(temp1 == -1) {
    text("Number of teams: _", 20, 245);
  } else if (temp2 == -1) {
    text("Number of teams: " + str(temp1), 20, 245);
  } else {
    text("Number of teams: " + str(temp1) + str(temp2), 20, 245);
  }
}

void setNumberOfEntries() {
  displayStatus();
  
  text("Enter number of entries,", 20, 150);
  text("between 1 and 99.", 20, 175);
  text("Press enter when done", 20, 220);

  if(temp1 == -1) {
    text("Number of entries: _", 20, 245);
  } else if (temp2 == -1) {
    text("Number of entries: " + str(temp1), 20, 245);
  } else {
    text("Number of entries: " + str(temp1) + str(temp2), 20, 245);
  }
}

void setUseAlarm() {
  displayStatus();
  
  text("Should alarm be enabled?", 20, 150);
  text("Press Y for yes and N for no", 20, 175);
  text("Press enter when done", 20, 220);
}

void setAlarmInterval() {
  displayStatus();
  
  text("Enter interval between alarms in minutes", 20, 150);
  text("Press enter when done", 20, 195);
  
  if(temp1 == -1) {
    text("Alarm interval: _", 20, 220);
  } else if (temp2 == -1) {
    text("Alarm interval: " + str(temp1), 20, 220);
  } else {
    text("Alarm interval: " + str(temp1) + str(temp2), 20, 220);
  }
}

void finishSetup() {
  displayStatus();
  text("Happy with the setup?", 20, 150);
  text("Press Y for yes and N for no", 20, 175);
}

void loadProgram() {
  width = 512;
  height = 200;
  minim = new Minim(this);
  waveform = new WaveformRenderer();
  surface.setTitle("Soundwave analyser");
  fill(0);
  
  team = new AudioPlayer[numberOfTeams];
  team_player = new int[numberOfTeams];
  team_isPlaying = new int[numberOfTeams];
  team_score = new int[numberOfTeams];
  String prefix = "team";
  String suffix = ".mp3";
  
  for(int i = 0; i < numberOfTeams; i++) {
    String currentTeam = str(i + 1);
    println("Loading team: " + prefix + currentTeam + suffix);
    team[i] = minim.loadFile(prefix + currentTeam + suffix, 1024);
  }
  
  if(useAlarm) {
    alarmWindow = new AlarmWindow();
    alarmStartTime = alarmWindow.millis();
    alarm_sound = minim.loadFile("alarm.mp3");
  }
  
  loadingIsComplete = true;
}

void checkExcel() { 
  reader = new XlsReader( this, "Pointscore.xls" );

  for (int h = 0; h < numberOfTeams; h++) { //Calculates the score for teams.
    for (int j = 0; j < numberOfEntries; j++) {
      current_cell = (reader.getInt(j+1, h+1)); //+1 sets the offset/indentation. See excel page.
      team_score[h] = team_score[h] + current_cell;
    }
  }
  
  for (int i = 0; i < team_player.length; i++) {
    if (team_score[i] > max) {
      pos = i;
      max = team_score[i];
    }
  }
  
  for (int k = 0; k < numberOfTeams; k++) {
    team_score[k] = 0;
  }
      
  last_song = current_song;
  current_song = pos;
      
  if ((last_song != current_song)) {
    playNewSong();
  }
}

void playNewSong() {
    team[last_song].removeListener(waveform);
    team[last_song].pause();
    team[last_song].rewind();
    
    team[current_song].addListener(waveform);
    team[current_song].loop();
    println("A new team is winning!");
    println("Team: " + pos + " with score: " + max);
}

void startAlarm(boolean initializeAlarm) {
  if(initializeAlarm) {
    println("Initialize alarm");
    team[current_song].removeListener(waveform);
    team[current_song].pause();
    team[current_song].rewind();
    
    alarm_sound.addListener(waveform);
    alarmStartTime = alarmWindow.millis();
    alarm_sound.play();
  }
  
  if((alarmWindow.millis() - alarmStartTime) >= alarm_sound.length()) {
    println("Ending alarm...");
    
    alarm_sound.removeListener(waveform);
    alarm_sound.pause();
    alarm_sound.rewind();
    
    alarmEndTime = alarmWindow.millis();
    alarmWindow.setPlayAlarmFalse();

    playNewSong();
  }
}
  

class AlarmWindow extends PApplet {
  static final String RENDERER = P2D;
  PFont TXTfont;
  
  int hours;
  int minutes;
  int seconds;
  
  private boolean playAlarm = false;

  AlarmWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(500, 200, RENDERER);
  }

  void setup() {
    background(0);
    TXTfont = createFont("Arial", 13);
  }

  public void draw() { //Code for drawing timer in xx:xx:xx format
    background(50);
    fill(255);
    textSize(72);
    textAlign(CENTER);
    
    float hours = (alarmEndTime + alarmInterval - millis())/1000/60/60; //converts millis into hours, minutes and seconds.
    float minutes = (alarmEndTime + alarmInterval - millis())/1000/60;
    float seconds = (alarmEndTime + alarmInterval - millis())/1000;
    
    hours_int = int(hours); //converts float to int.
    minutes_int = int(minutes) - (hours_int * 60);
    seconds_int = int(seconds) - (minutes_int * 60);
    
    String hours_s = str(hours_int); //converts int to string
    String minutes_s = str(minutes_int);
    String seconds_s = str(seconds_int);
    
    String joinedTime1 = hours_s + ":" + minutes_s + ":" + seconds_s; //joining hours, minutes and seconds into one string.
    String joinedTime2 = "0" + hours_s + ":" + minutes_s + ":" + seconds_s;
    String joinedTime3 = hours_s + ":" + "0" + minutes_s + ":" + seconds_s;
    String joinedTime4 = hours_s + ":" + minutes_s + ":" + "0" + seconds_s;
    String joinedTime5 = "0" + hours_s + ":" + "0" + minutes_s + ":" + seconds_s;
    String joinedTime6 = "0" + hours_s + ":" + minutes_s + ":" + "0" + seconds_s;
    String joinedTime7 = hours_s + ":" + "0" + minutes_s + ":" + "0" + seconds_s;
    String joinedTime8 = "0" + hours_s + ":" + "0" + minutes_s + ":" + "0" + seconds_s;
    
    if ((hours_int > 9) && (minutes_int > 9) && (seconds_int > 9)) {
      text(joinedTime1, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int < 10) && (minutes_int > 9) && (seconds_int > 9)) {
      text(joinedTime2, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int > 9) && (minutes_int < 10) && (seconds_int > 9)) {
      text(joinedTime3, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int > 9) && (minutes_int > 9) && (seconds_int < 10)) {
      text(joinedTime4, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int < 10) && (minutes_int < 10) && (seconds_int > 9)) {
      text(joinedTime5, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int < 10) && (minutes_int > 9) && (seconds_int < 10)) {
      text(joinedTime6, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int > 9) && (minutes_int < 10) && (seconds_int < 10)) {
      text(joinedTime7, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int < 10) && (minutes_int < 10) && (seconds_int < 10) && (seconds_int > -1)) {
      text(joinedTime8, width/2, (height/2)+20); //displays text/countdown.
    }
    if ((hours_int <= 0) && (minutes_int <= 0) && (seconds_int <= 0)) {
      playAlarm = true;
      text("Alarm!", width/2, (height/2)+20);
    }
  }
  
  public boolean playAlarm() {
    return playAlarm;
  }
  
  public void setPlayAlarmFalse() {
    playAlarm = false;
  }

  public void makeVisible(boolean state)
  {
    surface.setVisible(state);
  }
}
