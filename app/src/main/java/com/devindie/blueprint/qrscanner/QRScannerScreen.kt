package com.devindie.blueprint.qrscanner

import android.Manifest
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun QRScannerScreen(
    modifier: Modifier = Modifier,
    viewModel: QRScannerViewModel = hiltViewModel(),
    onBack: () -> Unit = {},
) {
    val uiState by viewModel.uiState.collectAsState()

    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
        onResult = { granted ->
            if (!granted) {
                viewModel.onError("Camera permission denied")
            }
        },
    )

    val requestOnce = remember { true }
    if (requestOnce) {
        cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
    }

    Box(modifier = modifier.fillMaxSize()) {
        Button(onClick = onBack) { Text(text = "Back") }

        when (uiState) {
            is QRScannerUiState.Loading -> {
                Text(text = "Starting camera...")
            }
            is QRScannerUiState.Success -> {
                val data = (uiState as QRScannerUiState.Success).data
                Text(text = "Scanned: $data")
                Log.i("QRScanner", "Scanned: $data")
            }
            is QRScannerUiState.Error -> {
                val msg = (uiState as QRScannerUiState.Error).message
                Text(text = "Error: $msg")
                Button(onClick = { cameraPermissionLauncher.launch(Manifest.permission.CAMERA) }) {
                    Text(text = "Retry")
                }
            }
        }
    }
}
