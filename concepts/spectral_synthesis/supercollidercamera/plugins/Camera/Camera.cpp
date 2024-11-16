// PluginCamera.cpp
// Evan Murray (emurray49@gatech.edu)
#include "SC_PlugIn.hpp"
#include <opencv2/objdetect.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/videoio.hpp>
#include <iostream>
#include <iomanip>

static InterfaceTable* ft;

namespace SuperColliderCamera {
struct CameraData {
    cv::VideoCapture cap;
};

CameraData gCameraData;

class Detector
{
    enum Mode { Default, Daimler } m;
    cv::HOGDescriptor hog, hog_d;
public:
    Detector() : m(Default), hog(), hog_d(cv::Size(48, 96), cv::Size(16, 16), cv::Size(8, 8), cv::Size(8, 8), 9)
    {
        hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
        hog_d.setSVMDetector(cv::HOGDescriptor::getDaimlerPeopleDetector());
    }
    void toggleMode() { m = (m == Default ? Daimler : Default); }
    std::string modeName() const { return (m == Default ? "Default" : "Daimler"); }
    std::vector<cv::Rect> detect(cv::InputArray img)
    {
        // Run the detector with default parameters. to get a higher hit-rate
        // (and more false alarms, respectively), decrease the hitThreshold and
        // groupThreshold (set groupThreshold to 0 to turn off the grouping completely).
        std::vector<cv::Rect> found;
        if (m == Default)
            hog.detectMultiScale(img, found, 0.1, cv::Size(8,8), cv::Size(), 1.05, 2, false);
        else if (m == Daimler)
            hog_d.detectMultiScale(img, found, 0.1, cv::Size(8,8), cv::Size(), 1.05, 2, true);
        return found;
    }
    void adjustRect(cv::Rect & r) const
    {
        // The HOG detector returns slightly larger rectangles than the real objects,
        // so we slightly shrink the rectangles to get a nicer output.
        r.x += cvRound(r.width*0.1);
        r.width = cvRound(r.width*0.8);
        r.y += cvRound(r.height*0.07);
        r.height = cvRound(r.height*0.8);
    }
};

class Camera : public SCUnit {
public:
    Camera()
    {
        mCalcFunc = make_calc_function<Camera, &Camera::next>();
        next(1);
    }
private:
    void next(int nSamples)
    {
        // Audio rate input
        const float* input = in(0);

        // Control rate parameter: gain.
        const float gain = in0(1);

        // Output buffer
        float* outbuf = out(0);

        // simple gain function
        for (int i = 0; i < nSamples; ++i) {
            outbuf[i] = input[i] * gain;
        }
    }
};

// Plugin Commands
void CameraCmd_on(World* inWorld, void* inUserData, struct sc_msg_iter* args, void* replyAddr)
{
    CameraData* cameraData = (CameraData*)inUserData;
    cameraData->cap = cv::VideoCapture{0};
}
} // namespace SuperColliderCamera

PluginLoad(CameraUGens) {
    // Plugin magic
    ft = inTable;
    registerUnit<SuperColliderCamera::Camera>(ft, "Camera", false);

    DefinePlugInCmd("on", SuperColliderCamera::CameraCmd_on, (void*)&SuperColliderCamera::gCameraData);
}
