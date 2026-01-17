package com.devindie.blueprint.data

import android.util.Log
import javax.inject.Inject

class QRCodeRepositoryImpl @Inject constructor() : QRCodeRepository {
    override suspend fun handleDecoded(value: String) {
        // For now just log the value; real implementations can persist or call APIs
        Log.i("QRCodeRepository", "Handled decoded QR: $value")
    }
}
