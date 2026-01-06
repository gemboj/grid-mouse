; Parts of this script are based on: https://gist.github.com/scottming/5405b12eb2c69a4e0e54

MyGui := Gui()
MyGui.Opt("+AlwaysOnTop")
MyGui.Opt("+Disabled")
MyGui.Opt("-SysMenu")
MyGui.Opt("+Owner") ; +Owner avoids a taskbar button.
MyGui.Opt("-Caption")
MyGui.Opt("-dpiscale")
MyGui.Opt("+Border")
MyGui.MarginX := 0
MyGui.MarginY := 0
MyGui.BackColor := "FFFFFF"
WinSetExStyle "^0x00000020", MyGui.Hwnd ; make the panel click-through, not sure how it works, this allows for scrolling while isActive and letting the cursor (and actual window elements, like hyperlinks) to react to the moving window
WinSetTransparent 50, MyGui.Hwnd

isActive := false

ScreenX := 
ScreenY := 
ScreenWidth :=
ScreenHeigth := 

CurrentXRadius :=
CurrentYRadius :=
CurrentWidth :=
CurrentHeight :=

ActiveMonitor := 1

; Number of columns in the grid
AreaSizeColumns := 3

; Number of rows in the grid
AreaSizeRows := 3

CommandHistory := []
CommandHistoryRedo := []
CommandHistoryMaxLength := 100

MouseLeftDown := false

AvailableActions := ["U", "I", "O", "J", "K", "L", "M", ",", "."]

TopRowH := [AvailableActions[1], AvailableActions[2], AvailableActions[3]]
MiddleRowH := [AvailableActions[4], AvailableActions[5], AvailableActions[6]]
BottomRowH := [AvailableActions[7], AvailableActions[8], AvailableActions[9]]
LeftRowV := [AvailableActions[1], AvailableActions[4], AvailableActions[7]]
MiddleRowV := [AvailableActions[2], AvailableActions[5], AvailableActions[8]]
RightRowV := [AvailableActions[3], AvailableActions[6], AvailableActions[9]]

SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Screen"

WHITE_BRUSH := 0
BLACK_BRUSH := 4

Persistent()
SetCapsLockState "AlwaysOff"

; Capslock + hjkl (left, down, up, right)
Capslock & h::Send "{Blind}{Left DownTemp}"
Capslock & h up::Send "{Blind}{Left Up}"

Capslock & j::Send "{Blind}{Down DownTemp}"
Capslock & j up::Send "{Blind}{Down Up}"

Capslock & k::Send "{Blind}{Up DownTemp}"
Capslock & k up::Send "{Blind}{Up Up}"

Capslock & l::Send "{Blind}{Right DownTemp}"
Capslock & l up::Send "{Blind}{Right Up}"

; Capslock + np (Page Down, Page Up)
Capslock & n::SendInput "{Blind}{PgDn Down}"
Capslock & n up::SendInput "{Blind}{PgDn Up}"

Capslock & p::SendInput "{Blind}{PgUp Down}"
Capslock & p up::SendInput "{Blind}{PgUp Up}"

; Cpaslock + -= (Home, End)
Capslock & -::SendInput "{Blind}{Home Down}"
Capslock & - up::SendInput "{Blind}{Home Up}"

Capslock & =::SendInput "{Blind}{End Down}"
Capslock & = up::SendInput "{Blind}{End Up}"

; Capslock only, Send Escape
#HotIf NOT isActive
{
    CapsLock::Send "{ESC}"
}

Esc::`

; Capslock & ESC, toggle Capslock
Capslock & ESC::
{
    If GetKeyState("CapsLock", "T") = 1
        SetCapsLockState "AlwaysOff"
    Else
        SetCapsLockState "AlwaysOn"
    Return
}

#HotIf NOT isActive
{
    Capslock & 1::
	{
        InitStartJump(1)
    }
    Return
}

#HotIf NOT isActive
{
    Capslock & 2::
	{
        InitStartJump(2)
    }
    Return
}

#HotIf NOT isActive
{
    Capslock & 3::
	{
        InitStartJump(3)
	}
    Return
}

#HotIf NOT isActive
{
    Capslock & 4::
	{
        InitStartJump(4)
	}
    Return
}

#HotIf isActive
{
    Capslock & 1::
	{
        InitJumpToStart(1)
	}
    Return
}

#HotIf isActive
{
    Capslock & 2::
	{
        InitJumpToStart(2)
	}
    Return
}

#HotIf isActive
{
    Capslock & 3::
	{
        InitJumpToStart(3)
	}
    Return
}

#HotIf isActive
{
    Capslock & 4::
	{
        InitJumpToStart(4)
	}
    Return
}

; Creates the area for the whole screen.
#HotIf NOT isActive
{
    Capslock & f::
	{
        InitStartJump(ActiveMonitor)
	}
    Return
}


InitStartJump(actMonitor)
{
    global ScreenX, ScreenY, ScreenWidth, ScreenHeight, ActiveMonitor
	ActiveMonitor := actMonitor
    CalcCurrentMonitor()

	StartJump(ScreenX, ScreenY, ScreenWidth, ScreenHeight) ; by default use the whole screen
}

CalcCurrentMonitor()
{
    global ActiveMonitor, ScreenWidth, ScreenHeight, ScreenX, ScreenY

	ScreenX := 0
	ScreenY := 0

    MonLeft := ""
    MonRight := ""
    MonTop := ""
    MonBottom := ""

	MonitorGet ActiveMonitor, &MonLeft, &MonTop, &MonRight, &MonBottom


	if (MonTop == "") ; make sure we intercept 'z' key when isActive, but ignore the action if no command was made
	{
	    ScreenWidth := A_ScreenWidth
	    ScreenHeight := A_ScreenHeight
	} else 
	{
        ScreenWidth := MonRight - MonLeft
        ScreenHeight := MonBottom - MonTop
	    ScreenX := MonLeft
	    ScreenY := MonTop
	}
}

; Jumps the area back to the default posititon of the screen.
#HotIf isActive
{
    Capslock & f::
	{
        InitJumpToStart(ActiveMonitor)
	}
    Return
}

; Creates the area for the current active window.
#HotIf NOT isActive
{
    Capslock & d::
	{
        CalcCurrentMonitor
    
	    X := ""
	    Y := ""
	    WindowWidth := ""
        WindowHeight := ""

    	WinGetPos &X, &Y, &WindowWidth, &WindowHeight, "A" ; A stands for active window
    
    	StartJump(X, Y, WindowWidth, WindowHeight)
    }
    Return
}

#HotIf isActive
{
    Capslock & d::
	{
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})

        CalcCurrentMonitor()

    	WinGetPos &X, &Y, &WindowWidth, &WindowHeight, "A" ; A stands for active window
    
    	StartJump(X, Y, WindowWidth, WindowHeight)
    }
    Return
}

; Activates area from the latest poision in the history.
#HotIf NOT isActive and commandHistory.Length > 0
{
    Capslock & z::
	{
    	command := CommandHistory.Pop()

    	CommandHistoryRedo.Push(command)
    	StartFromCommand(command)
    }
    Return
}

; Undoes the last Jump command
#HotIf isActive
{
    z::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	if (CommandHistory.Length < 1) ; make sure we intercept 'z' key when isActive, but ignore the action if no command was made
    	{
    		return
    	}
    
    	command := CommandHistory.Pop()
    	CommandHistoryRedo.Push({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    
    	CurrentXRadius := command.XRadius
    	CurrentYRadius := command.YRadius
    	CurrentX := command.X
    	CurrentY := command.Y
    
    	ActiveMonitor := command.ActiveMonitor
    
    	areaCenterVector := Vector(CurrentX, CurrentY)
    	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)
    
    	MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)
    
    	MouseMove CurrentX, CurrentY
    }
    Return
}

; Redoes the last command after previous undo.
#HotIf isActive
{
    Capslock & z::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor

    	if (CommandHistoryRedo.Length < 1) ; make sure we intercept 'z' key when isActive, but ignore the action if no command was made
    	{
    		return
    	}
    
    	command := CommandHistoryRedo.Pop()
    	CommandHistory.Push({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    
    	CurrentXRadius := command.XRadius
    	CurrentYRadius := command.YRadius
    	CurrentX := command.X
    	CurrentY := command.Y
    	ActiveMonitor := command.ActiveMonitor
    
    	areaCenterVector := Vector(CurrentX, CurrentY)
    	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)
    
    	MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)
    
    	MouseMove CurrentX, CurrentY
    }
    Return
}

#HotIf isActive
{
    u::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("U")
    }
    Return
}

#HotIf isActive
{
    i::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("I")
    }
    Return
}

#HotIf isActive
{
    o::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("O")
    }
    Return
}

#HotIf isActive
{
    j::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("J")
    }
    Return
}

#HotIf isActive
{
    k::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("K")
    }
    return
}


#HotIf isActive
{
    l::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("L")
    }
    Return
}

#HotIf isActive
{
    m::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump("M")
    }
    Return
}

#HotIf isActive
{
    ,::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump(",")
    }
    Return
}

#HotIf isActive
{
    .::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Jump(".")
    }
    Return
}

#HotIf isActive
{
    CapsLock & u::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe("U")
    }
    Return
}

#HotIf isActive
{
    CapsLock & i::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe("I")
    }
    Return
}

#HotIf isActive
{
    CapsLock & o::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe("O")
    }
    Return
}

#HotIf isActive
{
    CapsLock & j::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe("J")
    }
    Return
}

#HotIf isActive
{
    CapsLock & k::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Enlarge()
    }
    return
}

#HotIf isActive
{
    CapsLock & l::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe("L")
    }
    Return
}

#HotIf isActive
{
    CapsLock & m::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe("M")
    }
    Return
}

#HotIf isActive
{
    CapsLock & ,::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe(",")
    }
    Return
}

#HotIf isActive
{
    CapsLock & .::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	Strafe(".")
    }
    Return
}

#HotIf isActive
{
    CapsLock::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	StopJump()
    }
    return
}

#HotIf isActive
{
    Space::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	StopJump()
    	MouseClick
    }
    return
}

#HotIf isActive
{
    ^Space::
	{
	    global CurrentXRadius, CurrentYRadius, CurrentX, CurrentY, ActiveMonitor
    	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
    	StopJump()
    	MouseClick "Right"
    }
    return
}

#HotIf isActive
{
    f::
	{
    	MouseClick
    }
    return
}

#HotIf isActive
{
    ^f::
	{
    	Send "^{Click}"
    }
    return
}

#HotIf isActive
{
    s::
	{
    	MouseClick "Right"
    }
    return
}

#HotIf isActive
{
    Tab & f::
	{
	    global MouseLeftDown

	    if !MouseLeftDown
		{
    	    MouseLeftDown := true
    	    MouseClick "Left",,,,,"D" ; Send Left Mouse Button Down event
		} else
		{
    	    MouseLeftDown := false
    	    MouseClick "Left",,,,,"U" ; Send Left Mouse Button Up event
		}
    }
    return
}

#HotIf isActive
{
    d::
	{
    	Click "WheelUp", 2
    }
    Return
}

#HotIf isActive
{
    e::
	{
    	Click "Middle", 1
    }
    Return
}

#HotIf isActive
{
    c::
	{
    	Click "WheelDown", 2
    }
    Return
}

#HotIf isActive
{
    x::
	{
    	Click "WheelLeft", 2
    }
    Return
}

#HotIf isActive
{
    v::
	{
    	Click "WheelRight", 2
    }
    Return
}

#HotIf isActive
{
    w::
	{
    	Click "X1", 1 ; 4th mouse button
    }
    Return
}

#HotIf isActive
{
    r::
	{
    	Click "X2", 1 ; 5th mouse button
    }
    Return
}

CursorToRed()
{
	CursorHandle1 := DllCall("LoadCursorFromFile", "Str", "redpointer.cur")

	Cursors := "32512,0"
	Loop Parse, Cursors, ","
	{
		DllCall("SetSystemCursor", "Uint", CursorHandle1, "Int", A_Loopfield)
	}
}

CursorToDefault()
{
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0 )
}

InitJumpToStart(actMonitor)
{
    global

	addToCommandHistory({XRadius: CurrentXRadius, YRadius: CurrentYRadius, X: CurrentX, Y: CurrentY, ActiveMonitor: ActiveMonitor})
	ActiveMonitor := actMonitor

    CalcCurrentMonitor()

	JumpToStart(ScreenX, ScreenY, ScreenWidth, ScreenHeight)
}

JumpToStart(windowX, windowY, windowWidth, windowHeight)
{
	global

	CurrentXRadius := windowWidth / 2
	CurrentYRadius := windowHeight / 2

	CurrentX := windowX + windowWidth / 2
	CurrentY := windowY + windowHeight / 2

	areaCenterVector := Vector(CurrentX, CurrentY)
	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)

	MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)

	MouseMove CurrentX, CurrentY
}

Jump(key)
{
	global ; assume global mode - use variables from global scope by default

	CurrentXRadius := CurrentXRadius / 3
	CurrentYRadius := CurrentYRadius / 3

	position := CalculateCursorPosition(key, CurrentX, CurrentY, CurrentXRadius, CurrentYRadius)
	CurrentX := position.X
	CurrentY := position.Y

	areaCenterVector := Vector(CurrentX, CurrentY)
	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)

	MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)

	MouseMove CurrentX, CurrentY
}

Strafe(key)
{
	global ; assume global mode - use variables from global scope by default

	normalVector := CalculateNormalVector(key)

	absTravelDistanceX := CurrentXRadius/AreaSizeColumns
	absTravelDistanceY := CurrentYRadius/AreaSizeRows

	travelDistanceX := Abs(normalVector.X * absTravelDistanceX)
	travelDistanceY := Abs(normalVector.Y * absTravelDistanceY)

	CurrentX := CurrentX + travelDistanceX * normalVector.X
	CurrentY := CurrentY + travelDistanceY * normalVector.Y

	areaCenterVector := Vector(CurrentX, CurrentY)
	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)

	MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)

	MouseMove CurrentX, CurrentY
}

Enlarge()
{
	global ; assume global mode - use variables from global scope by default

	ratio := 3.0

	CurrentXRadius := CurrentXRadius * ratio
	CurrentYRadius := CurrentYRadius * ratio


	areaCenterVector := Vector(CurrentX, CurrentY)
	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)

	MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)
}

StopJump()
{
	global ; assume global mode - use variables from global scope by default

	if MouseLeftDown {
		MouseLeftDown := false
		MouseClick "Left",,,,,"U" ; Send Left Mouse Button Up event
	}

	MyGui.Hide

	isActive := false

	CursorToDefault()
}

StartJump(windowX, windowY, windowWidth, windowHeight)
{
	global ; assume global mode - use variables from global scope by default

	isActive := true

	CurrentXRadius := windowWidth / 2
	CurrentYRadius := windowHeight / 2

	CurrentX := windowX + windowWidth / 2
	CurrentY := windowY + windowHeight / 2

	areaCenterVector := Vector(CurrentX, CurrentY)
	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)

	CreateArea(AvailableActions, areaCenterVector, areaRadiusVector)

	CursorToRed()

	MouseMove CurrentX, CurrentY
}

StartFromCommand(command) {
	global

	isActive := true

	CurrentXRadius := command.XRadius
	CurrentYRadius := command.YRadius

	CurrentX := command.X
	CurrentY := command.Y

	areaCenterVector := Vector(CurrentX, CurrentY)
	areaRadiusVector := Vector(CurrentXRadius, CurrentYRadius)

	ActiveMonitor := command.ActiveMonitor

	CreateArea(AvailableActions, areaCenterVector, areaRadiusVector)

	CursorToRed()

	MouseMove CurrentX, CurrentY
}

; areaCenterVector is the point around which we will draw lines. It is relative to the whole visible area.
; areaRadiusVector represents half-size of the area where we will draw lines. It can be smaller than the whole area in case we want to draw lines on only some parts of it (e.g. when drawing smaller lines within rectangles recursively.
DisplayLines(areaCenterVector, areaRadiusVector, recursionLimit, hdc)
{
	global AvailableActions, WHITE_BRUSH, BLACK_BRUSH, AreaSizeColumns, AreaSizeRows

	If (recursionLimit <= 0) OR (recursionLimit <= 1 AND areaRadiusVector.X <= 50)
	{
		return
	}

	; Size of the letter prompt.
	; It is calculated by multiplying radius by 2 (to get a full length) and then divide by grid size.
	areaCellSizeVector := areaRadiusVector.MulXY(2/AreaSizeColumns, 2/AreaSizeRows)

    PS_DASH := 1
    NULL_BRUSH := 5
	; display different width/color based on area size and recursion level
	If (recursionLimit <= 1)
	{
		hPen := DllCall("CreatePen", "Int", PS_DASH, "Int", 1, "Int", 0x0000FF, "UInt")
		objB := DllCall("SelectObject", "UInt", hdc, "UInt", hPen, "UInt")
	}
	Else If (areaRadiusVector.X <= 200)
	{
		hPen := DllCall("CreatePen", "Int", PS_DASH, "Int", 1, "Int", 0x0, "UInt")
		objB := DllCall("SelectObject", "UInt", hdc, "UInt", hPen, "UInt")
	}
	Else
	{
		hPen := DllCall("CreatePen", "Int", PS_DASH, "Int", 3, "Int", 0x0, "UInt")
		objB := DllCall("SelectObject", "UInt", hdc, "UInt", hPen, "UInt")
	}

	brush := DllCall("GetStockObject", "Int", NULL_BRUSH, "UInt")
	objB := DllCall("SelectObject", "UInt", hdc, "UInt", brush, "UInt")

	lineSizeVector := Vector(2, 2)

	; Display rectangle around the whole area
;	DllCall("Rectangle", "UInt", hdc
;					, "Int", areaCenterVector.X - areaRadiusVector.X, "Int", areaCenterVector.Y - areaRadiusVector.Y
;					, "Int", areaCenterVector.X + areaRadiusVector.X, "Int", areaCenterVector.Y + areaRadiusVector.Y)

	; Display vertical lines between columns
	verticalLinesCount := AreaSizeColumns-1
	Loop verticalLinesCount {
		verticalLinePosition := areaCenterVector.X - areaRadiusVector.X + A_Index * areaCellSizeVector.X
		DllCall("Rectangle", "UInt", hdc
						, "Int", verticalLinePosition, "Int", areaCenterVector.Y - areaRadiusVector.Y
						, "Int", verticalLinePosition+(lineSizeVector.X-1), "Int", areaCenterVector.Y + areaRadiusVector.Y)
	}

	; Display horizontal lines between rows
	horizontalLinesCount := AreaSizeRows-1
	Loop horizontalLinesCount {
		horizontalLinePosition := areaCenterVector.Y - areaRadiusVector.Y + A_Index * areaCellSizeVector.Y
		DllCall("Rectangle", "UInt", hdc
						, "Int", areaCenterVector.X - areaRadiusVector.X, "Int", horizontalLinePosition
						, "Int", areaCenterVector.X + areaRadiusVector.X, "Int", horizontalLinePosition+(lineSizeVector.Y-1))
	}

	If (recursionLimit <= 1)
	{
		return
	}


	smallerRadius := areaRadiusVector.DivXY(AreaSizeColumns, AreaSizeRows)
	for index, element in AvailableActions
	{
		normalVector := CalculateNormalVector(element)
		point := areaCenterVector.Add(normalVector.Mul(areaCellSizeVector)).Sub(lineSizeVector)

		DisplayLines(point, smallerRadius, (recursionLimit - 1), hdc)
	}

	hPen := DllCall("CreatePen", "Int", PS_DASH, "Int", 1, "Int", 0x0, "UInt")
	objB := DllCall("SelectObject", "UInt", hdc, "UInt", hPen, "UInt")
	brush := DllCall("GetStockObject", "Int", NULL_BRUSH, "UInt")
	objB := DllCall("SelectObject", "UInt", hdc, "UInt", brush, "UInt")

	; Display dot at each rectangle
	for index, element in AvailableActions
	{
		; normal vector is the translation from the centerPoint to subCenterPoints by letterPromptSize times
		normalVector := CalculateNormalVector(element)
		point := areaCenterVector.Add(normalVector.Mul(areaCellSizeVector)).Sub(lineSizeVector)
		point2 := point.Add(lineSizeVector.AddXY(1, 1))

		DllCall("Rectangle", "UInt", hdc
					, "Int", point.X, "Int", point.Y
					, "Int", point2.X, "Int", point2.Y)
	}
}

CalculateCursorPosition(key, xCenter, yCenter, xRadius, yRadius)
{
	normalVector := CalculateNormalVector(key)

	x := xCenter
	y := yCenter

	If (normalVector.X = -1)
	{
		x := xCenter - 2*xRadius
	}
	else if (normalVector.X = 1)
	{
		x := xCenter + 2*xRadius
	}

	If (normalVector.Y = -1)
	{
		y := yCenter - 2*yRadius
	}
	else if (normalVector.Y = 1)
	{
		y := yCenter + 2*yRadius
	}

	return {X: x, Y: y}
}

CalculateNormalVector(key)
{
	x := 0
	y := 0

	global TopRowH
	global BottomRowH
	global LeftRowV
	global RightRowV

	If (HasVal(TopRowH, key).Ok)
	{
		y := -1
	}
	else if (HasVal(BottomRowH, key).Ok)
	{
		y := 1
	}

	If (HasVal(LeftRowV, key).Ok)
	{
		x := -1
	}
	else if (HasVal(RightRowV, key).Ok)
	{
		x := 1
	}

	return Vector(x, y)
}

CreateArea(AvailableActions, areaCenterVector, areaRadiusVector)
{
	global

	point := areaCenterVector.Sub(areaRadiusVector)
	x := point.X
	y := point.Y

	dimension := areaRadiusVector.MulXY(2, 2)
	w := dimension.X
	h := dimension.Y
	MyGui.Show "NoActivate x" . x . " y" . y . " w" . w . " h" . h

	hdc := DllCall("GetDC", "UInt", MyGui.Hwnd, "UInt")
	; the areaCenterVector is the center point of the whole visible area for the first iteration of drawing lines.
	DisplayLines(areaRadiusVector, areaRadiusVector, 2, hdc)
}

MoveArea(AvailableActions, areaCenterVector, areaRadiusVector)
{
	point := areaCenterVector.Sub(areaRadiusVector)
	x := point.X
	y := point.Y

	dimension := areaRadiusVector.MulXY(2, 2)
	w := dimension.X
	h := dimension.Y

	MyGui.Move x, y, w, h

	hdc := DllCall("GetDC", "UInt", MyGui.Hwnd, "UInt")

	; the areaCenterVector is the center point of the whole visible area for the first iteration of drawing lines.
	DisplayLines(areaRadiusVector, areaRadiusVector, 2, hdc)
    MyGui.Opt("+AlwaysOnTop")
}

HasVal(arr, elem) {
	for index, value in arr
	{
		if (value = elem)
		{
			return {Index: index, Ok: true}
		}
	}

	return {Index: 0, Ok: false}
}

addToCommandHistory(command){
	global CommandHistory, CommandHistoryRedo, CommandHistoryMaxLength
	a := command.ActiveMonitor
	CommandHistoryRedo := []

	if (CommandHistory.Length >= CommandHistoryMaxLength) {
		CommandHistory.RemoveAt(1)
	}

	CommandHistory.Push(command)
}

class Vector {
	__New(x, y) {
		this.x := x
		this.y := y
	}

	Add(inVector) {
		return Vector(this.X  + inVector.X, this.Y + inVector.Y)
	}

	Sub(inVector) {
		return Vector(this.X  - inVector.X, this.Y - inVector.Y)
	}

	AddXY(x, y) {
		return Vector(this.X  + x, this.Y + y)
	}

	Mul(inVector) {
		return Vector(this.X  * inVector.X, this.Y * inVector.Y)
	}

	MulXY(x, y) {
		return Vector(this.X  * x, this.Y * y)
	}

	DivXY(x, y) {
		return Vector(this.X  / x, this.Y / y)
	}

	; X coord of a Vector.
	X {
		get {
			return this.inX
		}
		set {
			return this.inX := value
		}
	}

	; Y coord of a Vector.
	Y {
		get {
			return this.inY
		}
		set {
			return this.inY := value
		}
	}
}
