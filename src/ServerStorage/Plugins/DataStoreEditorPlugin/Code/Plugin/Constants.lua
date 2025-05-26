local localDevVersion = script:IsDescendantOf(game:GetService("PluginDebugService"))

return {
	WidgetName = "DataStoreEditorV3",
	WidgetTitle = if localDevVersion then "DataStore Editor DEV" else "DataStore Editor",

	SideMenuWidth = 250,
	SideMenuButtonSize = 16,
	SideMenuPadding = 10,

	DataNil = {},
	MinMaxNil = {},

	Font = {
		Regular = Font.fromEnum(Enum.Font.BuilderSans),
		Bold = Font.fromEnum(Enum.Font.BuilderSansBold),
		Italic = Font.fromId(16658221428, Enum.FontWeight.Regular, Enum.FontStyle.Italic),
		Mono = Font.fromId(16658246179, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	},
}