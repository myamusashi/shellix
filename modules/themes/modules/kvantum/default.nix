{config, ...}: let
  color = config.shellix.matugen.colors.palette;
in {
  enable = true;
  text = ''
    ${builtins.readFile ./General.kvconfig}

    [GeneralColors]
    window.color=${color.background.hex}
    inactive.window.color=${color.background.hex}
    base.color=${color.background.hex}
    inactive.base.color=${color.background.hex}
    alt.base.color=${color.surface_container_low.hex}
    inactive.alt.base.color=${color.surface_container.hex}
    button.color=${color.surface_variant.hex}
    light.color=${color.surface_bright.hex}
    mid.light.color=${color.surface_container_highest.hex}:
    dark.color=${color.surface_container_lowest.hex}
    mid.color=${color.surface_container_high.hex}
    highlight.color=${color.primary.hex}
    inactive.highlight.color=${color.primary.hex}
    text.color=${color.on_background.hex}
    inactive.text.color=${color.on_surface_variant.hex}
    window.text.color=${color.on_background.hex}
    inactive.window.text.color=${color.on_surface_variant.hex}
    button.text.color=${color.on_background.hex}
    disabled.text.color=${color.outline.hex}
    tooltip.base.color=${color.surface_container.hex}
    tooltip.text.color=${color.on_background.hex}
    highlight.text.color=${color.on_primary.hex}
    inactive.highlight.text.color=${color.on_primary.hex}
    link.color=${color.primary.hex}
    link.visited.color=${color.tertiary.hex}
    progress.indicator.text.color=${color.on_primary.hex}

    ${builtins.readFile ./Hacks.kvconfig}

    [PanelButtonCommand]
    ${builtins.readFile ./PanelButtonCommand.kvconfig}
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_background.hex}
    text.press.color=${color.on_primary.hex}
    text.toggle.color=${color.on_primary.hex}

    ${builtins.readFile ./Focus.kvconfig}

    ${builtins.readFile ./PanelButtonTools.kvconfig}

    [ToolbarButton]
    ${builtins.readFile ./ToolbarButton.kvconfig}
    text.press.color=${color.on_primary.hex}
    text.toggle.color=${color.on_primary.hex}
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.normal.inactive.color=${color.surface_variant.hex}
    text.toggle.inactive.color=${color.surface_variant.hex}


    ${builtins.readFile ./ToolbarLineEdit.kvconfig}

    [Dock]
    ${builtins.readFile ./Dock.kvconfig}
    text.normal.color=${color.on_background.hex}

    [DockTitle]
    ${builtins.readFile ./DockTitle.kvconfig}
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}


    [IndicatorSpinBox]
    ${builtins.readFile ./IndicatorSpinBox.kvconfig}
    text.normal.color=${color.on_background.hex}

    [RadioButton]
    ${builtins.readFile ./RadioButton.kvconfig}
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}

    [CheckBox]
    ${builtins.readFile ./CheckBox.kvconfig}
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}

    ${builtins.readFile ./GenericFrame.kvconfig}

    ${builtins.readFile ./LineEdit.kvconfig}

    ${builtins.readFile ./DropDownButton.kvconfig}



    [ToolboxTab]
    inherits=PanelButtonCommand
    text.normal.color=${color.on_background.hex}
    text.press.color=${color.on_primary.hex}
    text.focus.color=${color.on_primary.hex}

    [Tab]
    ${builtins.readFile ./Tab.kvconfig}
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.press.color=${color.on_primary.hex}
    text.toggle.color=${color.on_primary.hex}
    text.toggle.inactive.color=${color.on_primary.hex}74

    ${builtins.readFile ./TabFrame.kvconfig}

    ${builtins.readFile ./TreeExpander.kvconfig}

    [SizeGrip]
    indicator.element=resize-grip

    [Toolbar]
    inherits=PanelButtonCommand
    indicator.element=toolbar
    indicator.size=10
    text.margin=0
    interior.element=toolbar
    frame.element=toolbar
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.normal.inactive.color=${color.on_background.hex}74
    frame.left=6
    frame.right=6
    frame.top=0
    frame.bottom=1
    frame.expansion=0

    [Slider]
    inherits=PanelButtonCommand
    frame.element=slider
    interior.element=slider
    frame.top=2
    frame.bottom=2
    frame.left=3
    frame.right=3

    [SliderCursor]
    inherits=PanelButtonCommand
    frame=false
    interior.element=slidercursor

    [Progressbar]
    inherits=PanelButtonCommand
    frame.element=progress
    interior.element=progress
    text.margin=0
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.press.color=${color.on_primary.hex}
    text.toggle.color=${color.on_primary.hex}
    text.bold=false
    frame.expansion=10

    [ProgressbarContents]
    inherits=PanelButtonCommand
    frame=true
    frame.element=progress-pattern
    frame.left=5
    frame.right=5
    interior.element=progress-pattern

    [ItemView]
    inherits=PanelButtonCommand
    text.margin=0
    frame.element=itemview
    interior.element=itemview
    frame.top=6
    frame.bottom=6
    frame.left=6
    frame.right=6
    text.margin.top=2
    text.margin.bottom=2
    text.margin.left=6
    text.margin.right=6
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.press.color=${color.on_primary.hex}
    text.toggle.color=${color.on_primary.hex}
    frame.expansion=6

    [Splitter]
    indicator.size=32

    [Scrollbar]
    inherits=PanelButtonCommand
    indicator.element=arrow
    indicator.size=10

    [ScrollbarSlider]
    inherits=PanelButtonCommand
    frame.element=scrollbarslider
    interior=false
    frame.left=6
    frame.right=6
    frame.top=6
    frame.bottom=6
    indicator.element=grip
    indicator.size=12
    frame.expansion=0

    [ScrollbarGroove]
    inherits=PanelButtonCommand
    interior=false
    frame=false

    [MenuBar]
    inherits=PanelButtonCommand
    frame.element=none
    interior.element=none
    frame.expansion=0

    [MenuBarItem]
    inherits=PanelButtonCommand
    interior=true
    interior.element=menubaritem
    frame.element=menubaritem
    frame.top=2
    frame.bottom=2
    frame.left=2
    frame.right=2
    text.margin.left=4
    text.margin.right=4
    text.margin.top=0
    text.margin.bottom=0
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.shadow.alpha=80
    frame.expansion=0

    [TitleBar]
    inherits=PanelButtonCommand
    frame=false
    interior.element=titlebar
    indicator.size=12
    indicator.element=mdi
    text.normal.color=${color.surface_variant.hex}
    text.focus.color=${color.on_background.hex}
    text.bold=true
    text.italic=true
    frame.expansion=0

    [Menu]
    inherits=PanelButtonCommand
    frame.top=9
    frame.bottom=9
    frame.left=9
    frame.right=9
    frame.element=menu
    interior.element=menu
    text.normal.color=${color.on_background.hex}

    [MenuItem]
    inherits=PanelButtonCommand
    frame=true
    frame.element=menuitem
    interior.element=menuitem
    indicator.element=menuitem
    text.normal.color=${color.on_background.hex}
    text.focus.color=${color.on_primary.hex}
    text.shadow=false
    text.margin.top=0
    text.margin.bottom=0
    text.margin.left=6
    text.margin.right=6
    frame.top=3
    frame.bottom=3
    frame.left=3
    frame.right=3
    frame.expansion=0

    [ComboBox]
    inherits=PanelButtonCommand
    indicator.element=comboarrow
    indicator.size=12

    [GroupBox]
    inherits=GenericFrame
    frame=true
    frame.element=group
    text.shadow=0
    text.margin=0
    interior=true
    interior.element=common
    frame.top=5
    frame.bottom=5
    frame.left=5
    frame.right=5
    text.normal.color=${color.on_background.hex}
    text.press.color=${color.on_primary.hex}
    text.focus.color=${color.on_primary.hex}
    text.normal.inactive.color=${color.on_background.hex}74
    text.toggle.inactive.color=${color.on_primary.hex}74
    text.bold=true
    text.boldness=2
    text.shadow=false
    text.shadow.color=black
    text.shadow.xshift=1
    text.shadow.yshift=1
    text.shadow.depth=1
    text.shadow.alpha=80

    frame.expansion=0
    interior.x.patternsize=20
    interior.y.patternsize=15

    [TabBarFrame]
    inherits=GenericFrame
    frame=false
    interior=false
    text.shadow=0

    [ToolTip]
    inherits=GenericFrame
    frame.top=3
    frame.bottom=3
    frame.left=3
    frame.right=3
    interior=true
    text.shadow=0
    text.margin=1
    text.margin.top=10
    text.margin.bottom=10
    text.margin.left=10
    text.margin.right=10
    interior.element=tooltip
    frame.element=tooltip
    frame.expansion=0

    [StatusBar]
    inherits=GenericFrame
    frame=false
    interior=false

    [Window]
    interior=true
    interior.element=window
    frame=true
    frame.element=window
    frame.bottom=10
    frame.top=10

    [Dialog]
    interior=true

  '';
}
