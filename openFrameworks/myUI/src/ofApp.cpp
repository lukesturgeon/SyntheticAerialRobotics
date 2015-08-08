#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    //    serial.listDevices();
    serial.setup("tty.usbmodem411", 9600);
    
    isSystemLockedToggle.setup("LOCKED", 10, 10, isSystemLocked);
    
//    isCalibrated.setup("MotorA: Uncalibrated", 10, 40);
    calibrateBtn.setup("CALIBRATE", 10, 70);
    zeroBtn.setup("ZERO", 10, 90);
    cwBtn.setup("STEP CW", 10, 120);
    ccwBtn.setup("STEP CCW", 10, 140);
    moveToBtn.setup("moveTo(s)", 10, 170);
    moveToMMBtn.setup("moveToMM(mm)", 10, 190);
    
    getPositionBtn.setup("GET LENGTH (?s / ?mm)", 10, 220);
    getStatusBtn.setup("GET STATUS (?c / ?l)", 10, 240);
    
    MyButton    positionBtn;
    MyButton    isCalibratedBtn;
    MyButton    isLockedBtn;
    
    ofAddListener(getPositionBtn.onTrigger, this, &ofApp::onBtnPress);
    ofAddListener(getStatusBtn.onTrigger, this, &ofApp::onBtnPress);
    //    ofAddListener(toggle1.onValueChange, this, &ofApp::onToggleChange);
    //    ofAddListener(slider1.onValueChange, this, &ofApp::onSlider1Change);
}

//--------------------------------------------------------------
void ofApp::onBtnPress(string &label) {
    if (label == getPositionBtn.label){
        ofxSendSerialString(serial, "?s\n"); // get currentStep
        ofxSendSerialString(serial, "?mm\n"); // get currentLength
    }
    
    if ( label == getStatusBtn.label ) {
        ofxSendSerialString(serial, "?c\n"); // get isCalibrated
        ofxSendSerialString(serial, "?l\n"); // get isSystemLocked
    }
}

void ofApp::ofxSendSerialString(ofSerial &serial, string str) {
    unsigned char* uc = new unsigned char[str.size()+1];
    memcpy(uc, str.c_str(), str.size());
    uc[str.size()]=0;
    serial.writeBytes(&uc[0], str.size());
    delete uc;
    
    serialLog.push_back(str);
}

string ofApp::ofxGetSerialString(ofSerial &serial, char until) {
    static string str;
    stringstream ss;
    char ch;
    int ttl=1000;
    while ((ch=serial.readByte())>0 && ttl-->0 && ch!=until) {
        ss << ch;
    }
    str+=ss.str();
    if (ch==until) {
        string tmp=str;
        str="";
        return ofxTrimString(tmp);
    } else {
        return "";
    }
}

string ofApp::ofxTrimString(string str) {
    return ofxTrimStringLeft(ofxTrimStringRight(str));;
}

string ofApp::ofxTrimStringLeft(string str) {
    str.erase(0, str.find_first_not_of(" \t\n\r\f\v"));
    return str;
}

string ofApp::ofxTrimStringRight(string str) {
    str.erase(str.find_last_not_of(" \t\n\r\f\v") + 1);
    return str;
}

//--------------------------------------------------------------
void ofApp::update(){
    
    // read data from arduino
    string str = ofxGetSerialString(serial, '\n');
    if ( str != "" ) {
        
        if ( str.substr(0,2) == "s=" ) {
            currentStep = ofToInt( str.substr(2, str.npos) );
        }
        
        else if ( str.substr(0,3) == "mm=" ) {
            currentLength = ofToInt( str.substr(3, str.npos) );
        }
        
        else if ( str.substr(0,2) == "l=" ) {
            isSystemLocked = (str.substr(2, 1) == "0") ? false : true;
        }
        
        else if ( str.substr(0,2) == "c=" ) {
            isCalibrated = (str.substr(2, 1) == "0") ? false : true;
        }
        
        else {
            cout << "[received] " << "'" << str << "'" << endl;
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofBackground(0);
    
    isSystemLockedToggle.draw();
    
    cwBtn.draw();
    ccwBtn.draw();
    zeroBtn.draw();
    calibrateBtn.draw();
    moveToBtn.draw();
    moveToMMBtn.draw();
    getPositionBtn.draw();
    getStatusBtn.draw();
    
    ofDrawBitmapString("-------------------------\nMOTOR A\n-------------------------", 240, 400);
    ofDrawBitmapString("Locked     = "+ofToString(isSystemLocked), 240, 440);
    ofDrawBitmapString("Calibrated = " + ofToString(isCalibrated), 240, 460);
    ofDrawBitmapString("Length(s)  = " + currentStep.toString(), 240, 480);
    ofDrawBitmapString("Length(mm) = " + currentLength.toString(), 240, 500);
    
    ofDrawBitmapString("-------------------------\nALL COMMANDS\n-------------------------\nu   = unlock\nl   = lock\nc   = calibrate\n?   = get status\nz   = reset\ns   = move to step [n]\nmm  = move to [n] mm\ncw  = 1 step CW\nccw = 1 step CCW\n-------------------------\n?s  = get steps\n?mm = get length\n?c  = get calibration\n?l  = get is locked", 10, 400);
    
    
    ofDrawBitmapString("-------------------------\nLOG\n-------------------------", 600, 40);
    for (int i = 0; i < serialLog.size(); i++) {
        ofDrawBitmapString(""+ofToString( serialLog[i] ), 600, 80+(20*i));
    }
    
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){
    
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){
    
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){
    
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){
    
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){
    
}
