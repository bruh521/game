local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local TextSize = require(script.Parent.Parent.Plugin.TextSize)
local ThemeContext = require(script.Parent.ThemeContext)
local Modal = require(script.Parent.Modal)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Button = require(script.Parent.Button)
local InputBox = require(script.Parent.InputBox)

local ExpandableInputBox = Roact.Component:extend("ExpandableInputBox")

function ExpandableInputBox:init()
	self.TextBoxRef = Roact.createRef()
	self.CanvasSize, self.SetCanvasSize = Roact.createBinding(UDim2.new(0, 0, 0, 0))
	self:setState({
		Expanded = not not self.props.ForceExpanded,
	})
end

function ExpandableInputBox:calcSize()
	local textBox = self.TextBoxRef:getValue()
	if not textBox then
		return
	end
	task.spawn(function()
		local textSize = TextSize.calc(textBox.FontFace, textBox.Text, textBox.TextSize)
		self.SetCanvasSize(UDim2.fromOffset(textSize.X, textSize.Y))
	end)
end

function ExpandableInputBox:setExpanded(isExpanded)
	self:setState({ Expanded = isExpanded })
	self.props.OnExpand(isExpanded)
end

function ExpandableInputBox:didUpdate(prevProps, prevState)
	if self.state.Expanded and not prevState.Expanded then
		self:calcSize()
	end
	if prevProps.ForceExpanded ~= self.props.ForceExpanded then
		self:setExpanded(self.props.ForceExpanded)
	end
end

function ExpandableInputBox:renderNormalInputBox()
	return Roact.createElement(InputBox, {
		OnExpand = function()
			self:setExpanded(true)
		end,
		Font = self.props.Font,
		Width = self.props.Width,
		Size = self.props.Size,
		LayoutOrder = self.props.LayoutOrder,
		Visible = self.props.Visible,
		Placeholder = self.props.Placeholder,
		Text = self.props.Text,
		Active = self.props.Active,
		MaxCharacters = self.props.MaxCharacters,
		ForceFocus = self.props.ForceFocus,
		FilterText = self.props.FilterText,
		OnInput = self.props.OnInput,
		OnCleared = self.props.OnCleared,
		OnFocusLost = self.props.OnFocusLost,
	})
end

function ExpandableInputBox:render()
	if not self.state.Expanded then
		return self:renderNormalInputBox()
	end

	-- Transform text to format properly within the multiline textbox:
	local text = self.props.Text
	if text then
		if text:sub(1, 1) == '"' and text:sub(#text) == '"' then
			if not tonumber(text:sub(2, #text - 1)) then
				text = text:sub(2, #text - 1)
			end
		end
		text = text:gsub("\\n", "\n"):gsub("\\r", "\r")
	end

	return Roact.createElement(Modal, {
		Visible = true,
		NoClickDismiss = true,
		Dismiss = function()
			self:setExpanded(false)
		end,
	}, {
		ExpandedEditorView = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					BackgroundColor3 = theme.MainBackground.Default,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0.7, 0, 0.7, 0),
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
					}),
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					Buttons = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 30),
					}, {
						Title = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							FontFace = Constants.Font.Bold,
							Text = 'Editing "' .. self.props.Key .. '"',
							TextSize = 16,
							TextColor3 = theme.MainText.Default,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),
						SetButton = Roact.createElement(Button, {
							Label = "Set",
							ImageColor = "DialogMainButton",
							TextColor = "DialogMainButtonText",
							AnchorPoint = Vector2.new(1, 0),
							Size = UDim2.new(0, 80, 1, 0),
							Position = UDim2.new(1, -90, 0, 0),
							Disabled = (self.state.InputProfileName == ""),
							OnActivated = function(_rbx)
								local textBox = self.TextBoxRef:getValue()
								if not textBox then
									return
								end
								local txt = textBox.Text
								if type(self.props.OnSet) == "function" then
									self.props.OnSet(txt)
								end
								self:setExpanded(false)
							end,
						}),
						CancelButton = Roact.createElement(Button, {
							Label = "Cancel",
							ImageColor = "CheckedFieldBorder",
							TextColor = "DialogMainButtonText",
							AnchorPoint = Vector2.new(1, 0),
							Size = UDim2.new(0, 80, 1, 0),
							Position = UDim2.new(1, 0, 0, 0),
							Disabled = (self.state.InputProfileName == ""),
							OnActivated = function(_rbx)
								if type(self.props.OnCancel) == "function" then
									self.props.OnCancel()
								end
								self:setExpanded(false)
							end,
						}),
					}),
					EditArea = Roact.createElement("Frame", {
						BackgroundColor3 = theme.InputFieldBackground.Default,
						Size = UDim2.new(1, 0, 1, -40),
						Position = UDim2.new(0, 0, 0, 40),
					}, {
						UIPadding = Roact.createElement("UIPadding", {
							PaddingBottom = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
							PaddingTop = UDim.new(0, 10),
						}),
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),
						ScrollingFrame = Roact.createElement(ScrollingFrame, {
							Size = UDim2.new(1, 0, 1, 0),
							CanvasSize = self.CanvasSize,
							IgnoreUIListLayout = true,
							KeepShadowInBounds = true,
						}, {
							TextBox = Roact.createElement("TextBox", {
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 1, 0),
								FontFace = Constants.Font.Mono,
								Text = text or "",
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Top,
								TextColor3 = theme.MainText.Default,
								TextSize = 16,
								ClearTextOnFocus = false,
								MultiLine = true,
								[Roact.Ref] = self.TextBoxRef,
								[Roact.Change.Text] = function()
									self:calcSize()
								end,
							}),
						}),
					}),
				})
			end,
		}),
	})
end

return ExpandableInputBox