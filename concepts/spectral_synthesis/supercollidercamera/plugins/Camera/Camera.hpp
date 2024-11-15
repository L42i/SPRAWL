// PluginCamera.hpp
// Evan Murray (emurray49@gatech.edu)

#pragma once

#include "SC_PlugIn.hpp"

#include <opencv2/objdetect.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/videoio.hpp>
#include <iostream>
#include <iomanip>

namespace SuperColliderCamera {

class Camera : public SCUnit {
public:
    Camera();

    // Destructor
    // ~Camera();

private:
    // Calc function
    void next(int nSamples);

    // Member variables
};

} // namespace SuperColliderCamera
