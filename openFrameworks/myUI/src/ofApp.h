#pragma once

#include "ofMain.h"
#include "MyGUI.h"

class ofApp : public ofBaseApp{
    
public:
    void setup();
    void update();
    void draw();
    
    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    
    ofParameter<int> currentStep;
    ofParameter<int> currentLength;
    ofParameter<bool> isSystemLocked;
    ofParameter<bool> isCalibrated;
    
    deque<string> serialLog;
    
    MyToggle    isSystemLockedToggle;
    
    
    
    MyButton    getPositionBtn;
    MyButton    getStatusBtn;
    MyButton    cwBtn;
    MyButton    ccwBtn;
    MyButton    zeroBtn;
    MyButton    calibrateBtn;
    MyButton    moveToBtn;
    MyButton    moveToMMBtn;
    
    //    MyLabel     isCalibrated;
    
    ofSerial	serial;
    
    void onBtnPress(string &label);
    void ofxSendSerialString(ofSerial &serial, string s);
    string ofxGetSerialString(ofSerial &serial, char until);
    string ofxTrimString(string str);
    string ofxTrimStringLeft(string str);
    string ofxTrimStringRight(string str);
    
};
