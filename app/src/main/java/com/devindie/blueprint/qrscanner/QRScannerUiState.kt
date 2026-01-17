package com.devindie.blueprint.qrscanner

sealed interface QRScannerUiState {
    object Loading : QRScannerUiState
    data class Success(val data: String) : QRScannerUiState
    data class Error(val message: String) : QRScannerUiState
}
