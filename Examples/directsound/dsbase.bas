'dsbase ds基础库
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#pragma once
#include once "dsbase.bi"

Private Function DSoundEnumCallback(ByVal pGUID As LPGUID, ByVal strDesc As LPCWSTR, ByVal strDrvName As LPCWSTR, ByVal pContext As LPVOID) As WINBOOL
	(*Cast(ComboBoxEdit Ptr, pContext)).AddItem *Cast(WString Ptr, strDesc)
	Dim i As Integer = (*Cast(ComboBoxEdit Ptr, pContext)).ItemCount - 1
	(*Cast(ComboBoxEdit Ptr, pContext)).ItemData(i) = pGUID
	Return True
End Function

Private Sub WaveFormatSet(Samples As Integer, Bits As Integer, Channels As Integer, pwfx As WAVEFORMATEX Ptr)
	ZeroMemory(pwfx, SizeOf(WAVEFORMATEX))
	pwfx->wFormatTag = WAVE_FORMAT_PCM
	pwfx->nSamplesPerSec = Samples
	pwfx->wBitsPerSample = IIf(Bits = 8, 8, 16)
	pwfx->nChannels = IIf(Channels = 2, 2, 1)
	pwfx->nBlockAlign = pwfx->nChannels * (pwfx->wBitsPerSample / 8)
	pwfx->nAvgBytesPerSec = pwfx->nBlockAlign * pwfx->nSamplesPerSec
	pwfx->cbSize = 0 'SizeOf(WAVEFORMATEX)
End Sub

Private Sub WaveFormat2Combo(Cb1 As LPVOID, Cb2 As LPVOID, Cb3 As LPVOID)
	Cast(ComboBoxEdit Ptr, Cb1)->Clear
	Cast(ComboBoxEdit Ptr, Cb1)->AddItem "8000"
	Cast(ComboBoxEdit Ptr, Cb1)->AddItem "11025"
	Cast(ComboBoxEdit Ptr, Cb1)->AddItem "22050"
	Cast(ComboBoxEdit Ptr, Cb1)->AddItem "44100"
	Cast(ComboBoxEdit Ptr, Cb1)->AddItem "48000"
	Cast(ComboBoxEdit Ptr, Cb1)->ItemData(0) = Cast(Any Ptr, 8000)
	Cast(ComboBoxEdit Ptr, Cb1)->ItemData(1) = Cast(Any Ptr, 11025)
	Cast(ComboBoxEdit Ptr, Cb1)->ItemData(2) = Cast(Any Ptr, 22050)
	Cast(ComboBoxEdit Ptr, Cb1)->ItemData(3) = Cast(Any Ptr, 44100)
	Cast(ComboBoxEdit Ptr, Cb1)->ItemData(4) = Cast(Any Ptr, 48000)
	
	Cast(ComboBoxEdit Ptr, Cb2)->Clear
	Cast(ComboBoxEdit Ptr, Cb2)->AddItem "8"
	Cast(ComboBoxEdit Ptr, Cb2)->AddItem "16"
	Cast(ComboBoxEdit Ptr, Cb2)->ItemData(0) = Cast(Any Ptr, 8)
	Cast(ComboBoxEdit Ptr, Cb2)->ItemData(1) = Cast(Any Ptr, 16)
	
	Cast(ComboBoxEdit Ptr, Cb3)->Clear
	Cast(ComboBoxEdit Ptr, Cb3)->AddItem "1"
	Cast(ComboBoxEdit Ptr, Cb3)->AddItem "2"
	Cast(ComboBoxEdit Ptr, Cb3)->ItemData(0) = Cast(Any Ptr, 1)
	Cast(ComboBoxEdit Ptr, Cb3)->ItemData(1) = Cast(Any Ptr, 2)
	
	Cast(ComboBoxEdit Ptr, Cb1)->ItemIndex = 3
	Cast(ComboBoxEdit Ptr, Cb2)->ItemIndex = 1
	Cast(ComboBoxEdit Ptr, Cb3)->ItemIndex = 1
End Sub
