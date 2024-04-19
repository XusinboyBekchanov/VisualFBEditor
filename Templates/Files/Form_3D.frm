'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	Using My.Sys.Forms
	
	'This is where you define module-level Shared variables and Add include file.
	'The "RenderProj" sub is the main rendering code subroutine.
	'在这儿定义模块级别共享变量和添加引用。“RenderProj”过程是主要的渲染代码主过程。
	Declare Sub RenderProj(Param As Any Ptr)
	
	'' include fbgfx.bi for some useful definitions
	'#include once "fbgfx.bi"
	'Using FB
	
	'if drawing with RayLib
	#include once "inc/raymath.bi"
	#include once "inc/raylib.bi"
	Using RayLib
	'
	'初始化相机
	Dim Shared As RayLib.Camera3D Camera
	#ifdef __USE_WINAPI__
		Dim Shared As HWND HandleRender
	#endif
	
	Type Form1Type Extends Form
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Panel PanelRender
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
			.Text = "VisualFBEditor-3D"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 350, 300
		End With
		
		' PanelRender
		With PanelRender
			.Name = "PanelRender"
			.Text = "PanelRender"
			.TabIndex = 2
			.BackColor = 8421376
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 90, 10, 230, 240
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = False
		Form1.MainForm = True
		Form1.Show
		' Put the Render code here
		'ThreadCreate_(@RenderProj, 0)
		RenderProj(0)
		App.Run
	#endif
'#End Region

	'the main rendering code.  渲染代码主过程。
	Sub RenderProj(Param As Any Ptr)
		#ifdef __fbgfx_bi__
			
		#elseif defined(RAYLIB_H)
			While RayLib.WindowShouldClose = False
				Dim t As Double = GetTime()
				'每循环更新一帧
				Dim cameraTime As Double = t
				Camera.position.x = Cos(cameraTime) * 40
				Camera.position.z = Sin(cameraTime) * 40
				RayLib.BeginDrawing()
				RayLib.ClearBackground(WHITE)
				RayLib.BeginMode3D(Camera) '以相机视角绘制3d
				
				RayLib.DrawGrid(100, 5) '绘制水平面网格
				'绘制立方体
				RayLib.DrawCube(Type(0, 0, 0), 10, 10, 10, VIOLET)
				RayLib.DrawCubeWires(Type(0, 0, 0), 10, 10, 10, BLACK)
				'绘制球体
				RayLib.DrawSphere(Type(0, -40, 0), 10, RED)
				RayLib.EndMode3D()
				RayLib.EndDrawing()
				'ThreadsEnter
				
				'ThreadsLeave
			Wend
		#endif
	End Sub
	
Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	'Initialize the drawing engine in sub Form_Create or Form_Show. The official freeBasic drawing engine is fbgfx,
	'and third-party drawing engines like RayLib are employed. It cannot be mixed simultaneously.
	'在Form_Create或者Form_Show初始化绘图引擎。freeBasic官方绘图引擎是fbgfx，第三方绘图引擎如RayLib。不能同时混用。
	Dim As Integer IMAGE_W = ScaleX(PanelRender.Width)
	Dim As Integer IMAGE_H = ScaleY(PanelRender.Height)
	#ifdef __fbgfx_bi__
		ScreenRes IMAGE_W, IMAGE_H, 32
		ScreenControl(2, Cast(Integer, HandleRender))
	#elseif defined(RAYLIB_H)
		RayLib.SetConfigFlags(FLAG_MSAA_4X_HINT) '启用反锯齿
		RayLib.InitWindow(IMAGE_W, IMAGE_H, "RaylibWindows")
		HandleRender = RayLib.GetWindowHandle
		If HandleRender = 0 Then
			Debug.Print("Failed to create RayLib window")
			Return
		End If
		RayLib.SetTargetFPS(60) '设置动画帧率(fps)
		SetExitKey(0)
		With Camera
			.position   = Type(40, 20, 0)
			.target     = Type(0, 0, 0)
			.up         = Type(0, 1, 0)
			.fovy       = 70
			.projection = CAMERA_PERSPECTIVE
		End With
	#endif
	
	'Move the render windows to container PanelRender.
	'将渲染绘画窗口移动到容器PanelRender。
	If HandleRender > 0 Then
		SetParent(HandleRender, PanelRender.Handle)
		SetWindowLongW(HandleRender, GWL_STYLE, WS_VISIBLE)
		MoveWindow(HandleRender, 0, 0, IMAGE_W, IMAGE_H, True)
	End If
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	#if defined(__fbgfx_bi__)
		
	#elseif defined(RAYLIB_H)
		MoveWindow(HandleRender, 0, 0, ScaleX(PanelRender.Width), ScaleY(PanelRender.Height), True)
	#endif
End Sub

Private Sub Form1Type.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	Ending = True
	#ifdef __fbgfx_bi__
		'cairo_destroy(cairoCreate)
		'cairo_surface_destroy(cairoSurface)
		'ImageDestroy image
	#elseif defined(RAYLIB_H)
		RayLib.CloseWindowRL
	#endif
End Sub