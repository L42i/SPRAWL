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
} // namespace SuperColliderCamera

PluginLoad(CameraUGens) {
    // Plugin magic
    ft = inTable;
    registerUnit<SuperColliderCamera::Camera>(ft, "Camera", false);
}
