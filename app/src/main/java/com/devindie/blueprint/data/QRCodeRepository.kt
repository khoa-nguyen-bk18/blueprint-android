package com.devindie.blueprint.data

interface QRCodeRepository {
    suspend fun handleDecoded(value: String)
}
