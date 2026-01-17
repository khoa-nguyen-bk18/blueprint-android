package com.devindie.blueprint.util

import android.app.Activity

object CameraPermissionHelper {
    fun shouldShowRationale(activity: Activity): Boolean = activity.run { false }
}
