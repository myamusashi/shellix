{
    lib,
    config,
    inputs,
    ...
}: let
    cfg = config.shellix.programs.home.walker;
    colors = config.shellix.matugen.colors.palette;
in {
    imports = [inputs.walker.homeManagerModules.default];
    config = lib.mkIf cfg.enable {
        programs.walker = {
            enable = true;
            runAsService = true;

            config = {
                search.placeholder = "euy";
                ui.fullscreen = true;
                list = {
                    height = 200;
                };
                websearch.prefix = "?";
                switcher.prefix = "/";
            };
            theme.style = ''
                @define-color window_bg_color ${colors.background.hex};
                @define-color accent_bg_color ${colors.on_tertiary_fixed_variant.hex};
                @define-color theme_fg_color ${colors.on_surface.hex};
                @define-color theme_primary_color ${colors.primary.hex};
                @define-color theme_secondary_color ${colors.secondary.hex};
                @define-color theme_tertiary_color ${colors.tertiary.hex};

                * {
                	all: unset;
                }

                .normal-icons {
                	-gtk-icon-size: 16px;
                }

                .large-icons {
                	-gtk-icon-size: 32px;
                }

                .scrollbar {
                	opacity: 0;
                }

                .box-wrapper {
                	box-shadow: 0 19px 38px rgba(0,0,0,0.3), 0 15px 12px rgba(0,0,0,0.22);
                	background: @window_bg_color;
                	padding: 20px;
                	border-radius: 20px;
                	border: 1px solid ${colors.surface_variant.hex};
                }

                .preview-box,
                .elephant-hint,
                .placeholder {
                  color: @theme_fg_color;
                }

                .box {
                  background-color: @window_bg_color;
                }

                .search-container {
                  border-radius: 10px;
                  background-color: @window_bg_color;
                }

                .input placeholder {
                  opacity: 0.5;
                  color: @theme_fg_color;
                }

                .input {
                  caret-color: @theme_fg_color;
                  background: ${colors.surface_container_low.hex};
                  padding: 10px;
                  color: @theme_fg_color;
                  border-radius: 10px;
                }

                .input:focus,
                .input:active {
                  border: 1px solid @theme_primary_color;
                  background-color: ${colors.surface_container.hex};
                }

                .content-container {
                  background-color: @window_bg_color;
                }

                .placeholder {
                  font-style: italic;
                  opacity: 0.7;
                }

                .scroll {
                  background-color: @window_bg_color;
                }

                .list {
                  color: @theme_fg_color;
                }

                child {
                  background-color: transparent;
                }

                .item-box {
                  border-radius: 10px;
                  padding: 10px;
                }

                child:hover .item-box,
                child:selected .item-box {
                  background: #${colors.on_tertiary_fixed_variant.strip}54;
                }

                .item-text-box {
                  background-color: transparent;
                }

                .item-text {
                  color: @theme_fg_color;
                }

                .item-subtext {
                  font-size: 12px;
                  opacity: 0.5;
                  color: @theme_fg_color;
                }

                .item-image {
                  margin-right: 10px;
                  color: @theme_primary_color;
                }

                .keybind-hints {
                  opacity: 0.5;
                  color: @theme_fg_color;
                }

                .preview {
                  border: 1px solid #${colors.on_tertiary_fixed_variant.strip}54;
                  padding: 10px;
                  border-radius: 10px;
                  color: @theme_fg_color;
                  background-color: @window_bg_color;
                }

                .calc .item-text {
                  font-size: 24px;
                  color: @theme_primary_color;
                }

                .calc .item-subtext {
                  color: @theme_secondary_color;
                }

                .symbols .item-image {
                  font-size: 24px;
                  color: @theme_tertiary_color;
                }

                .todo.done .item-text-box {
                  opacity: 0.25;
                }

                .todo.urgent {
                  font-size: 24px;
                  color: ${colors.error.hex};
                }

                .todo.active {
                  font-weight: bold;
                  color: @theme_primary_color;
                }

                .preview .large-icons {
                  -gtk-icon-size: 64px;
                }
            '';
        };
    };
}
