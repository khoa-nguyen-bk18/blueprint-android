package com.devindie.blueprint.qrscanner

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.devindie.blueprint.data.QRCodeRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class QRScannerViewModel @Inject constructor(
    private val repository: QRCodeRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<QRScannerUiState>(QRScannerUiState.Loading)
    val uiState: StateFlow<QRScannerUiState> = _uiState.asStateFlow()

    fun onQrDecoded(value: String) {
        viewModelScope.launch {
            repository.handleDecoded(value)
            _uiState.value = QRScannerUiState.Success(value)
        }
    }

    fun onError(message: String) {
        _uiState.value = QRScannerUiState.Error(message)
    }
}
