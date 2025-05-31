local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local ThemeController = require(script.Parent.ThemeController)
local Alert = require(script.Parent.Alert)
local Container = require(script.Parent.Container)
local SideMenu = require(script.Parent.SideMenu)
local DataContainer = require(script.Parent.DataContainer)
local KeyListContainer = require(script.Parent.KeyListContainer)
local StoreListContainer = require(script.Parent.StoreListContainer)
local VersionLabel = require(script.Parent.VersionLabel)
local SetPlaceId = require(script.Parent.SetPlaceId)
local SaveProfile = require(script.Parent.SaveProfile)
local LoadProfile = require(script.Parent.LoadProfile)
local DeleteKey = require(script.Parent.DeleteKey)
local LoadingScreen = require(script.Parent.LoadingScreen)

local Main = Roact.Component:extend("Main")

local function createElementIf(condition, ...)
	if condition then
		return Roact.createElement(...)
	end
	return nil
end

function Main:loadInfo()
	self.props.SetLoaded(true)
end

function Main:didMount()
	self._mounted = true
	self:loadInfo()
end

function Main:willUnmount()
	self._mounted = false
end

function Main:didUpdate(prevProps)
	if prevProps.Loaded ~= self.props.Loaded then
		if not self.props.Loaded then
			self:loadInfo()
		end
	end
end

function Main:render()
	return Roact.createElement(ThemeController, {}, {
		Main = Roact.createElement(Container, {
			Visible = self.props.ShowFrame == "Main" and self.props.Loaded,
		}, {
			SideMenu = Roact.createElement(SideMenu),
			DataContainer = createElementIf(self.props.ConnectedView == "DataContainer", DataContainer),
			KeyListContainer = createElementIf(self.props.ConnectedView == "KeyListContainer", KeyListContainer),
			StoreListContainer = createElementIf(self.props.ConnectedView == "StoreListContainer", StoreListContainer),
			VersionLabel = createElementIf(self.props.ConnectedView == "", VersionLabel),
		}),
		PlaceId = Roact.createElement(Container, {
			Visible = self.props.ShowFrame == "PlaceId" and self.props.Loaded,
		}, {
			SetPlaceId = Roact.createElement(SetPlaceId),
		}),
		SaveProfile = Roact.createElement(Container, {
			Visible = self.props.ShowFrame == "SaveProfile" and self.props.Loaded,
		}, {
			SaveProfile = Roact.createElement(SaveProfile, {
				IsVisible = self.props.ShowFrame == "SaveProfile" and self.props.Loaded,
			}),
		}),
		LoadProfile = Roact.createElement(Container, {
			Visible = self.props.ShowFrame == "LoadProfile" and self.props.Loaded,
		}, {
			LoadProfile = Roact.createElement(LoadProfile, {
				IsVisible = self.props.ShowFrame == "LoadProfile" and self.props.Loaded,
			}),
		}),
		DeleteKey = Roact.createElement(Container, {
			Visible = self.props.ShowFrame == "DeleteKey" and self.props.Loaded,
		}, {
			DeleteKey = Roact.createElement(DeleteKey),
		}),
		Loading = Roact.createElement(Container, {
			Visible = not self.props.Loaded,
			Padding = 10,
		}, {
			LoadingScreen = Roact.createElement(LoadingScreen),
		}),
		Alert = Roact.createElement(Alert, {
			Showing = self.props.ShowAlert,
			Title = self.props.AlertTitle,
			Message = self.props.AlertMessage,
			OnHide = function()
				self.props.HideAlert()
			end,
		}),
	})
end

Main = RoactRodux.connect(function(state)
	return {
		ShowFrame = state.ShowFrame,
		Loaded = state.Loaded,
		ShowAlert = state.ShowAlert,
		AlertTitle = state.AlertTitle,
		AlertMessage = state.AlertMessage,
		ConnectedView = state.ConnectedView,
	}
end, function(dispatch)
	return {
		SetLoaded = function(isLoaded)
			dispatch({ type = "Loaded", IsLoaded = isLoaded })
		end,
		HideAlert = function()
			dispatch({ type = "HideAlert" })
		end,
	}
end)(Main)

return Main