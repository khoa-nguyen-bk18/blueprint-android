package com.devindie.blueprint.di

import com.devindie.blueprint.data.QRCodeRepository
import com.devindie.blueprint.data.QRCodeRepositoryImpl
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class QrScannerModule {

    @Binds
    @Singleton
    abstract fun bindQrRepository(impl: QRCodeRepositoryImpl): QRCodeRepository
}
