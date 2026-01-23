/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.devindie.blueprint.ui.login

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devindie.blueprint.ui.theme.MyApplicationTheme

@Composable
fun LoginScreen(
    modifier: Modifier = Modifier,
    onNavigateToMain: () -> Unit = {},
    viewModel: LoginViewModel = hiltViewModel(),
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(uiState) {
        if (uiState is LoginUiState.Success) {
            onNavigateToMain()
        }
    }

    LoginScreen(
        uiState = uiState,
        onLogin = viewModel::login,
        modifier = modifier,
    )
}

@Composable
internal fun LoginScreen(
    uiState: LoginUiState,
    onLogin: (String, String) -> Unit,
    modifier: Modifier = Modifier,
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = "Login",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 32.dp),
        )

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            enabled = uiState !is LoginUiState.Loading,
        )

        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            visualTransformation = PasswordVisualTransformation(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            enabled = uiState !is LoginUiState.Loading,
        )

        if (uiState is LoginUiState.Error) {
            Text(
                text = uiState.message,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 16.dp),
            )
        }

        if (uiState is LoginUiState.Loading) {
            CircularProgressIndicator(modifier = Modifier.padding(bottom = 16.dp))
        }

        Button(
            onClick = { onLogin(email, password) },
            enabled = uiState !is LoginUiState.Loading,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("Login")
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun LoginScreenIdlePreview() {
    MyApplicationTheme {
        LoginScreen(
            uiState = LoginUiState.Idle,
            onLogin = { _, _ -> },
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun LoginScreenLoadingPreview() {
    MyApplicationTheme {
        LoginScreen(
            uiState = LoginUiState.Loading,
            onLogin = { _, _ -> },
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun LoginScreenErrorPreview() {
    MyApplicationTheme {
        LoginScreen(
            uiState = LoginUiState.Error("Invalid credentials"),
            onLogin = { _, _ -> },
        )
    }
}
