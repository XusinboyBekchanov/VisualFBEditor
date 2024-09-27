' enumdevices设备枚举
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "enumdevices.bi"

Private Function FreeDirectSound() As HRESULT
	SAFE_RELEASE(g_pDS)
	SAFE_RELEASE(g_pDSCapture)
	Return S_OK
End Function

Private Function InitDirectSound(pSoundGUID As GUID Ptr, pCaptureGUID As GUID Ptr) As HRESULT
	Dim As HRESULT hr
	
	'free Any previous DirectSound objects
	FreeDirectSound()
	
	'Create IDirectSound Using the Select sound device
	hr = DirectSoundCreate(pSoundGUID, @g_pDS, NULL)
	DXTRACE_MSG("DirectSoundCreate", hr)
	If hr Then Return hr
	
	'Create IDirectSoundCapture Using the Select capture device
	hr = DirectSoundCaptureCreate(pCaptureGUID, @g_pDSCapture, NULL)
	DXTRACE_MSG("DirectSoundCaptureCreate", hr)
	If hr Then Return hr
	
	Return S_OK
	
End Function

