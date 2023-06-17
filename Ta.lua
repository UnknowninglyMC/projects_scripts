local ReplicatedStorage = game:GetService("ReplicatedStorage") 
 local UserInputService = game:GetService("UserInputService") 
 local RunService = game:GetService("RunService") 
 local LocalPlayer = game.Players.LocalPlayer 
 local Alert = getsenv(game.Players.LocalPlayer.PlayerScripts.CL_MAIN_GameScript).newAlert 
 local Key = -game.ReplicatedStorage.Remote.ReqPasskey:InvokeServer() 
 local AnimationState = {} 
 local Savestates = {} 
 local PlayerInfo = {} 
 local TimePaused = 0 
 local Pause = true 
 local TimePauseHolder 
 local SenvAnimation 
 local PlayAnimation 
 local TimeStart 
 local TimeText 
 local function ReturnPlayerInfo() 
     return { 
             CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame, 
             CameraCFrame = Workspace.CurrentCamera.CFrame, 
             Velocity = LocalPlayer.Character.HumanoidRootPart.Velocity, 
             Animation = AnimationState, 
             Time = tick() - TimeStart - TimePaused, 
     } 
 end 
 local function SetPrimaryPart() 
     local CharacterParts = {} 
     local Character = LocalPlayer.Character 
     local Ray = Ray.new(Character.HumanoidRootPart.Position,Vector3.new(0,-10,0)) 
     if game.Workspace.CurrentCamera:FindFirstChild("ShadowPt") then 
         table.insert(CharacterParts,game.Workspace.CurrentCamera.ShadowPt) 
     end 
     for i,v in pairs(game.Players:GetPlayers()) do 
         pcall(function() 
             for j,k in pairs(v.Character:GetChildren()) do 
                 if k:IsA("Part") then 
                     table.insert(CharacterParts,k) 
                 end 
             end 
         end)  
     end 
     while true do 
         local hit,pos = game.Workspace:FindPartOnRayWithIgnoreList(Ray,CharacterParts) 
         if hit:IsA("Part") and math.floor(hit.Size.X) == math.floor(hit.Size.Z) then 
             game.Workspace.Multiplayer.Map.PrimaryPart = hit 
             break 
         else 
             table.insert(CharacterParts,hit) 
         end 
     end 
 end 
 local function SetUpGui() 
     for i,v in pairs(LocalPlayer.PlayerGui.GameGui.HUD.Main.GameStats:GetChildren()) do 
         if v:IsA("Frame") then 
             v.Visible = false 
         end 
     end 
     TimeText = Instance.new("TextLabel") 
     TimeText.Name = "TimeText" 
     TimeText.Parent = LocalPlayer.PlayerGui.GameGui.HUD.Main.GameStats 
     TimeText.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
     TimeText.BackgroundTransparency = 1.000 
     TimeText.Position = UDim2.new(0.030, 0, 0.35, 0) 
     TimeText.Size = UDim2.new(0, 100, 0, 27) 
     TimeText.Font = Enum.Font.Highway 
     TimeText.Text = "0:00:000" 
     TimeText.TextColor3 = Color3.fromRGB(255, 255, 0) 
     TimeText.TextSize = 60 
     TimeText.TextXAlignment = Enum.TextXAlignment.Left 
     LocalPlayer.PlayerGui.GameGui.Challenges.Visible = false 
 end 
 local function SetUpMap() 
     local Map 
     local CurrentInfo 
     function game.ReplicatedStorage.Remote.ReqCharVars.OnClientInvoke() return {} end 
     SetPrimaryPart() 
     Map = game.Workspace.Multiplayer.Map:Clone() 
     Map.Parent = game.Workspace 
     Map:MoveTo(Vector3.new(0,1000,0)) 
     LocalPlayer.Character.Head:Destroy() 
     LocalPlayer.CharacterAdded:Wait() 
     LocalPlayer.Character:WaitForChild("Humanoid") 
     LocalPlayer.Character:WaitForChild("HumanoidRootPart") 
     ReplicatedStorage.Remote.RemoveWaiting:FireServer(Key) 
     LocalPlayer.Character.Humanoid.WalkSpeed = 0 
     LocalPlayer.Character.Humanoid.JumpPower = 0 
     task.wait(0.5) 
     LocalPlayer.Character.Humanoid.WalkSpeed = 0 
     LocalPlayer.Character.Humanoid.JumpPower = 0 
     LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Map.PrimaryPart.Position) + Vector3.new(0,Map.PrimaryPart.Size.Y/2,0) + Vector3.new(0,LocalPlayer.Character.HumanoidRootPart.Size.Y/2,0) + Vector3.new(0,LocalPlayer.Character["Left Leg"].Size.Y,0) 
     task.wait(0.5) 
     LocalPlayer.Character.HumanoidRootPart.Anchored = true 
     LocalPlayer.Character.Humanoid.WalkSpeed = 20 
     LocalPlayer.Character.Humanoid.JumpPower = 50 
     table.insert(Savestates,{{ 
         CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame, 
         CameraCFrame = game.Workspace.CurrentCamera.CFrame, 
         Velocity = Vector3.new(0,0,0), 
         Animation = {"idle",0}, 
         Time = 0 
     }}) 
     SetUpGui() 
     SenvAnimation = getsenv(game.Players.LocalPlayer.Character.Animate) 
     PlayAnimation = SenvAnimation.playAnimation 
     TimePauseHolder = tick() 
     TimeStart = tick() 
     function SenvAnimation.playAnimation(a,b) 
         if not Pause then 
             AnimationState = {a,b} 
             PlayAnimation(AnimationState[1],AnimationState[2], LocalPlayer.Character.Humanoid) 
         end 
     end 
 end 
 local function SetTimeGui() 
     local TimePlayed = tick() - TimeStart - TimePaused 
     local m = math.floor(TimePlayed / 60) 
     local s = math.floor(TimePlayed % 60) 
     local ms = math.floor((TimePlayed * 1000) % 1000) 
     m = tostring(m) 
     s = tostring(s) 
     ms = tostring(ms) 
     for i=1, 2 do if #ms < 3 then ms = '0' .. ms end end 
     for i=1, 1 do if #s < 2 then s = '0' .. s end end 
     TimeText.Text = m .. ":" .. s .. ":" .. ms 
 end 
 local function UserPause() 
     Pause = not Pause 
     if Pause then 
         LocalPlayer.Character.HumanoidRootPart.Anchored = true 
         TimeText.TextColor3 = Color3.fromRGB(255, 255, 0) 
         TimePauseHolder = tick() 
     else 
         LocalPlayer.Character.HumanoidRootPart.Anchored = false 
         TimeText.TextColor3 = Color3.fromRGB(255,255,255) 
         TimePaused = TimePaused + tick() - TimePauseHolder 
     end 
 end 
 local function BackSavestate() 
     local InfoState = Savestates[#Savestates][#Savestates[#Savestates]] 
     PlayerInfo = {} 
     Pause = true 
     LocalPlayer.Character.HumanoidRootPart.Anchored = true 
     TimeText.TextColor3 = Color3.fromRGB(255, 255, 0) 
     LocalPlayer.Character.HumanoidRootPart.CFrame = InfoState.CFrame 
     LocalPlayer.Character.HumanoidRootPart.Velocity = InfoState.Velocity 
     game.Workspace.CurrentCamera.CFrame = InfoState.CameraCFrame 
     TimePauseHolder = tick() 
     TimeStart = tick() - InfoState.Time 
     TimePaused = 0 
     PlayAnimation(InfoState.Animation[1],InfoState.Animation[2],LocalPlayer.Character.Humanoid) 
     if InfoState.Animation[1] == "walk" then 
         SenvAnimation.setAnimationSpeed(.76) 
     end 
     SetTimeGui() 
 end 
 local function AddSavestate() 
     Alert("Added Savestate",Color3.fromRGB(0, 255, 0),1) 
     table.insert(Savestates,PlayerInfo) 
     PlayerInfo = {} 
 end 
 local function RemoveSavestate() 
     if #Savestates > 1 then 
         Alert("Removed Savestate",Color3.fromRGB(0, 255, 0),1) 
         table.remove(Savestates) 
         BackSavestate() 
     else 
         Alert("No Savestate",Color3.fromRGB(255, 0, 0),1) 
     end 
 end 
 local function CollisionToggler() 
     local MouseTarget = game.Players.LocalPlayer:GetMouse().Target 
     MouseTarget.CanCollide = not MouseTarget.CanCollide 
     if MouseTarget.CanCollide then 
         MouseTarget.Transparency = 0 
     else 
         MouseTarget.Transparency = 1 
     end 
 end 
 local function SaveRun() 
     local AllPlayerInfo = {} 
     for i=2,#Savestates do 
         for j=1,#Savestates[i] do 
             local InfoFromSavestates = Savestates[i][j] 
             local InfoAddingToAllPlayerInfo = {} 
             local a,b,c = InfoFromSavestates.CFrame:ToEulerAnglesXYZ() 
             local d,e,f  = InfoFromSavestates.CameraCFrame:ToEulerAnglesXYZ() 
             InfoAddingToAllPlayerInfo.CFrame = {InfoFromSavestates.CFrame.X, InfoFromSavestates.CFrame.Y, InfoFromSavestates.CFrame.Z, a, b, c} 
             InfoAddingToAllPlayerInfo.Animation = InfoFromSavestates.Animation 
             InfoAddingToAllPlayerInfo.CameraCFrame = {InfoFromSavestates.CameraCFrame.X, InfoFromSavestates.CameraCFrame.Y, InfoFromSavestates.CameraCFrame.Z, d, e, f} 
             InfoAddingToAllPlayerInfo.Time = InfoFromSavestates.Time 
             table.insert(AllPlayerInfo,InfoAddingToAllPlayerInfo) 
         end 
     end 
     local i = -1 
     repeat i = i + 1 until not isfile("tas/" .. game.Workspace.Map.Settings.MapName.Value .. tostring(i) .. ".json") 
     writefile("tas/" .. game.Workspace.Map.Settings.MapName.Value .. tostring(i) .. ".json", game:GetService("HttpService"):JSONEncode(AllPlayerInfo)) 
     Alert("Saved",Color3.fromRGB(0,255,0),1) 
 end 
 ReplicatedStorage.Remote.StartClientMapTimer.OnClientEvent:Wait() 
 task.wait(1) 
 SetUpMap() 
 if not isfolder("tas") then 
     makefolder("tas") 
 end 
 RunService.Heartbeat:Connect(function() 
     if not Pause then 
         SetTimeGui() 
         table.insert(PlayerInfo,ReturnPlayerInfo()) 
     end 
 end) 
 UserInputService.InputBegan:Connect(function(Key,Typing) 
     if not Typing then 
         Key = Key.KeyCode.Name 
         if Key == "CapsLock" then 
             UserPause() 
         elseif Key == "One" then 
             AddSavestate() 
         elseif Key == "Two" then 
             RemoveSavestate() 
         elseif Key == "Three" then 
             BackSavestate() 
         elseif Key == "Four" then 
             CollisionToggler() 
         elseif Key == "Five" then 
             SaveRun() 
         end 
     end 
 end)
 if UserInputService.TouchEnabled then

for _, v in pairs(game.CoreGui:GetChildren()) do
	if v.Name == "TASUI" then
		v:Destroy()
	end
end

local TASUI = Instance.new("ScreenGui")

TASUI.Name = "TASUI"
TASUI.Parent = game.CoreGui

local function getNextWindowPos()
	local biggest = 0;
	local ok = nil;
	for i, v in pairs(TASUI:GetChildren()) do
		if v.Position.X.Offset > biggest then
			biggest = v.Position.X.Offset
			ok = v;
		end
	end
	if biggest == 0 then
		biggest = biggest + 5;
	else
		biggest = biggest + ok.Size.X.Offset + 5;
	end
	
	return biggest;
end

local Library = {}

function Library:Window(title, color)
	color = color or Color3.fromRGB(0, 100, 255)
	local visible = true
	local Window = Instance.new("Frame")
	local WindowCover = Instance.new("UICorner")
	local Title = Instance.new("TextLabel")
	local Body = Instance.new("Frame")
	local BodyCover = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")
	local UIPadding = Instance.new("UIPadding")
	local Arrow = Instance.new("ImageButton")

	Window.Name = "Window"
	Window.Parent = TASUI
	Window.BackgroundColor3 = color
	Window.BorderSizePixel = 0
	Window.Position = UDim2.new(0, getNextWindowPos() + 10, 0, 10)
	Window.Size = UDim2.new(0, 109, 0, 36)
	Window.ZIndex = 2
	Window.Active = true
	Window.Draggable = true
	
    WindowCover.CornerRadius = UDim.new(0, 4)
    WindowCover.Name = "WindowCover"
    WindowCover.Parent = Window
    
	Title.Name = "Title"
	Title.Parent = Window
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.Size = UDim2.new(0.80733943, 0, 1, 0)
	Title.ZIndex = 2
	Title.Font = Enum.Font.SourceSans
	Title.Text = title
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.TextSize = 14.000
	Title.TextWrapped = true

	Body.Name = "Body"
	Body.Parent = Window
	Body.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Body.Size = UDim2.new(1, 0, 0, 0)
    
    BodyCover.CornerRadius = UDim.new(0, 4)
    BodyCover.Name = "BodyCover"
    BodyCover.Parent = Body
    
	UIListLayout.Parent = Body
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	UIPadding.Parent = Body
	UIPadding.PaddingTop = UDim.new(0, 36)

	Arrow.Name = "Arrow"
	Arrow.Parent = Window
	Arrow.BackgroundTransparency = 1.000
	Arrow.Position = UDim2.new(0.816513717, 0, 0.21282047, 0)
	Arrow.Size = UDim2.new(0.176643878, 0, 0.527777791, 0)
	Arrow.ZIndex = 2
	Arrow.Image = "rbxassetid://3926305904"
	Arrow.ImageRectOffset = Vector2.new(924, 884)
	Arrow.ImageRectSize = Vector2.new(36, 36)
	Arrow.Rotation = 90

	Arrow.MouseButton1Down:connect(function()
		if visible == true then
			Body:TweenSize(UDim2.fromScale(1, 0))
			for _, v in pairs(Body:GetChildren()) do
				if v:IsA("Frame") then
					v:TweenSize(UDim2.new(1, 0, 0, 0))
				end
			end
			game:GetService("TweenService"):Create(Arrow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Rotation = 0
			}):Play();
			wait(0.7)
			Body.Visible = false
			visible = false
		else
			Body:TweenSize(UDim2.fromScale(1, 0))
			for _, v in pairs(Body:GetChildren()) do
				if v:IsA("Frame") then
					v:TweenSize(UDim2.new(1, 0, 0, 36))
				end
			end
			game:GetService("TweenService"):Create(Arrow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Rotation = 90
			}):Play();
			wait(0.1)
			Body.Visible = true
			wait(0.9)
			visible = true
		end
	end)

	local Lib = {}

	function Lib:Button(name, callback)
		local ButtonContainer = Instance.new("Frame")
		local ButtonCover = Instance.new"UICorner"
		local Button = Instance.new("TextButton")

		ButtonContainer.Name = "ButtonContainer"
		ButtonContainer.Parent = Body
		ButtonContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		ButtonContainer.BackgroundTransparency = 0
		ButtonContainer.BorderSizePixel = 0
		ButtonContainer.Size = UDim2.new(1, 0, 0, 36)
   
       
    ButtonCover.CornerRadius = UDim.new(0, 4)
    ButtonCover.Name = "ButtonCover"
    ButtonCover.Parent = ButtonContainer
   
		Button.Name = "Button"
		Button.Parent = ButtonContainer
		Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Button.BackgroundTransparency = 1.000
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.Font = Enum.Font.SourceSans
		Button.Text = name
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextSize = 24.000
		
    local btn = ButtonContainer
    local sample = Button
    
		Button.MouseButton1Down:connect(function()
			callback()
			ButtonContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
		end)
   

	end

	return Lib;

end

local Window = Library:Window("TAS")

-- ################ Dont Remove This
Window:Button("HI", function()
end)
-- ################

Window:Button("Pause", function()
   UserPause()
end)

Window:Button("Add_SaveState", function()
   AddSavestate()
end)

Window:Button("Remove_SaveState", function()
   RemoveSavestate()
end)

Window:Button("Back_SaveState", function()
   BackSavestate()
end)

Window:Button("Collision_Toggler", function()
   CollisionToggler()
end)
Window:Button("Save", function()
   SaveRun()
end)

-- Bug Never Wins
game.Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
for _, v in pairs(game.CoreGui:GetChildren()) do
	if v.Name == "TASUI" then
		v:Destroy()
	end
end
end)

return Library;
end