#pragma once

#include "ofMain.h"

class MyGUI {
public:
    ofPoint         position;
    ofRectangle     hitArea;
    string          label;
    bool            isHover;
    
    void setup(string _label, int _x, int _y){
        label = _label;
        position.set(_x,_y);
        hitArea.set(_x, _y, 200, 19);
        ofRegisterMouseEvents( this, OF_EVENT_ORDER_BEFORE_APP );
    }
    
    virtual void draw(){};
    
    virtual void mouseMoved(ofMouseEventArgs &a){
        if(hitArea.inside(a.x, a.y)){
            isHover = true;
        } else {
            isHover = false;
        }
    };
    
    virtual void mouseDragged(ofMouseEventArgs &a){};
    virtual void mousePressed(ofMouseEventArgs &a){};
    virtual void mouseReleased(ofMouseEventArgs &a){};
};

//===============================================================
class MyButton : public MyGUI {
public:
    
    ofEvent<string> onTrigger;
    
    void draw(){
        ofSetColor( (isHover) ? 120 : 100 );
        ofRect(hitArea);
        ofSetColor(255);
        ofDrawBitmapString(label, position.x+6, position.y+14);
    }
    
    void mousePressed(ofMouseEventArgs &a){
        if(hitArea.inside(a.x, a.y)){
            ofNotifyEvent(onTrigger, label);
        }
    };
};

//===============================================================
class MyToggle : public MyGUI {
public:
    
    ofEvent<bool> onValueChange;
    
    bool val;
    
    void setup(string _label, int _x, int _y, bool _default){
        MyGUI::setup(_label, _x, _y);
        hitArea.width = hitArea.height;
        val = _default;
    }
    
    void draw(){
        if(val == true){
            ofSetColor(100, 255, 100);
        } else {
            ofSetColor( (isHover) ? 120 : 100 );
        }
        ofRect(hitArea);
        ofSetColor(255);
        ofDrawBitmapString(label, position.x+6+hitArea.width, position.y+14);
    }
    
    void mousePressed(ofMouseEventArgs &a){
        if (hitArea.inside(a.x, a.y)){
            val = !val;
            ofNotifyEvent(onValueChange, val);
        }
    };
};

//===============================================================
class MySlider : public MyGUI {
public:
    
    ofEvent<float> onValueChange;
    
    float val, min, max;
    
    void setup(string _label, int _x, int _y, float _val, float _min, float _max) {
        MyGUI::setup(_label, _x, _y);
        val = _val;
        min = _min;
        max = _max;
    }
    
    void draw(){
        ofSetColor( (isHover) ? 120 : 100 );
        ofRect(hitArea);
        
        ofSetColor( 100, 255, 100 );
        ofRect(hitArea.x, hitArea.y, ofMap(val, min, max, 0, hitArea.width), hitArea.height);
        
        ofSetColor(255);
        ofDrawBitmapString(label + ":" + ofToString(val), position.x+6, position.y+14);
    }
    
    void mouseDragged(ofMouseEventArgs &a){
        if (isHover && a.x >= hitArea.x && a.x <= hitArea.x+hitArea.width ){
            val = ofMap(a.x, hitArea.x, hitArea.x+hitArea.width, min, max);
            ofNotifyEvent(onValueChange, val);
        }
        
        if (isHover && a.x < hitArea.x){
            if (val != min){
                val = min;
                ofNotifyEvent(onValueChange, val);
            }
        }
        
        if (isHover && a.x > hitArea.x+hitArea.width){
            if (val != max){
                val = max;
                ofNotifyEvent(onValueChange, val);
            }
        }
    };
};

//===============================================================
class MyLabel : public MyGUI {
public:
    void draw(){
        ofSetColor(100);
        ofRect(hitArea);
        ofSetColor(255);
        ofDrawBitmapString(label, position.x+6, position.y+14);
    }
};

//===============================================================
class MyGraph : public MyGUI {
public:
    
    deque <float> vals;
    float highest;
    float lowest = FLT_MAX;
    
    void setup(string _label, int _x, int _y) {
        MyGUI::setup(_label, _x, _y);
        hitArea.height = 100;
    }
    
    void addVal(float val){
        vals.push_back(val);
        
        if (vals.size() > hitArea.width){
            vals.pop_front();
        }
        
        if (val > highest) {
            highest = val;
        }

        if (val < lowest){
            lowest = val;
        }
    }
    
    void draw(){
        ofSetColor( (isHover) ? 120 : 100 );
        ofRect(hitArea);
        
        ofSetColor(100, 255, 100);
        for (int i = vals.size()-1; i >= 0; i--) {
            ofRect(hitArea.x+i, ofMap(vals[i], lowest, highest, hitArea.y+hitArea.height, hitArea.y, true), 1,
                   ofMap(vals[i], lowest, highest, 0, hitArea.height, true));
        }
        
        ofSetColor(255);
        ofDrawBitmapString(label+":"+ofToString(vals.back()), position.x+6, position.y+14);
        ofDrawBitmapString("min:"+ofToString(highest), position.x+6, position.y+14+20);
        ofDrawBitmapString("max:"+ofToString(lowest), position.x+6, position.y+14+40);
    }
    
    void mousePressed(ofMouseEventArgs &a){
        if (hitArea.inside(a.x, a.y)){
            highest = 0;
            lowest = FLT_MAX;
        }
    };
};