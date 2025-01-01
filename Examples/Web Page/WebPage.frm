'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	#ifdef __FB_JS__
		#define OnClient
	#else
		#define OnServer
	#endif
	
	#ifdef OnClient
		#include once "mff/Form.bi"
		#include once "mff/CommandButton.bi"
		#include once "mff/HTTP.bi"
		
		Using My.Sys.Forms
		
		Type Form1Type Extends Form
			Declare Sub CommandButton1_Click(ByRef Sender As Control)
			Declare Constructor
			
			Dim As CommandButton CommandButton1
			Dim As HTTPConnection HTTP
		End Type
		
		Constructor Form1Type
			#if _MAIN_FILE_ = __FILE__
				With App
					.CurLanguagePath = ExePath & "/Languages/"
					.CurLanguage = .Language
				End With
			#endif
			' Form1
			With This
				.Name = "Form1"
				.Text = "Form1"
				.Designer = @This
				.SetBounds 0, 0, 350, 300
			End With
			' CommandButton1
			With CommandButton1
				.Name = "CommandButton1"
				.Text = "CommandButton1"
				.TabIndex = 0
				.SetBounds 90, 90, 160, 50
				.Designer = @This
				.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
				.Parent = @This
			End With
			With HTTP
				.Name = "HTTP"
				.Host = "localhost"
				.Port = 8000
			End With
		End Constructor
	#endif
	
	#ifdef OnServer
		#include once "mff/Form.bi"
		#include once "mff/HTTPServer.bi"
		
		Using My.Sys.Forms
		
		Type frmServerType Extends Form
			Declare Sub Server_Receive(ByRef Sender As HTTPServer, ByRef Request As HTTPServerRequest, ByRef Responce As HTTPServerResponce)
			Declare Constructor
			
			Dim As HTTPServer Server
		End Type
		
		Constructor frmServerType
			#if _MAIN_FILE_ = __FILE__
				With App
					.CurLanguagePath = ExePath & "/Languages/"
					.CurLanguage = .Language
				End With
			#endif
			' Form1
			With This
				.Name = "frmServer"
				.Text = "Server"
				.Designer = @This
				.SetBounds 0, 0, 350, 300
			End With
			With Server
				Server.Name = "Server"
				Server.Address = "127.0.0.1"
				Server.Port = 8000
				Server.Designer = @This
				Server.OnReceive = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPServer, ByRef Request As HTTPServerRequest, ByRef Responce As HTTPServerResponce), @Server_Receive)
				Server.Run
			End With
		End Constructor
	#endif
	
	#ifdef OnClient
		Dim Shared Form1 As Form1Type
		
		#if _MAIN_FILE_ = __FILE__
			App.DarkMode = True
			Form1.MainForm = True
			Form1.Show
			App.Run
		#endif
	#endif
	
	#ifdef OnServer
		Dim Shared frmServer As frmServerType
		
		#if _MAIN_FILE_ = __FILE__
			App.DarkMode = True
			frmServer.MainForm = True
			frmServer.Show
			App.Run
		#endif
	#endif
'#End Region

#ifdef OnClient
	Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
		Dim As HTTPRequest Request
		Dim As HTTPResponce Responce
		Request.ResourceAddress = "Untitled.html"
		Request.Headers = ""
		Request.Body = "{key: value}"
		HTTP.CallMethod("POST", Request, Responce)
		?Responce.StatusCode, Responce.Body
	End Sub
#endif

#ifdef OnServer
	Private Sub frmServerType.Server_Receive(ByRef Sender As HTTPServer, ByRef Request As HTTPServerRequest, ByRef Responce As HTTPServerResponce)
		If Request.HTTPMethod = "POST" Then
			If Request.Body = "{key: value}" Then
				Responce.Body = "true"
			End If
		End If
	End Sub
#endif

