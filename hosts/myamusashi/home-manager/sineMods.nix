{
    "Arc-2.0" = {
        id = "Arc-2.0";
        name = "Arc 2.0";
        description = "Arc-like Zen Browser theme.";
        homepage = "https://github.com/YashjitPal/Arc-2.0";
        version = "3.3.3";
        style = {
            chrome = "userChrome.css";
            content = "userContent.css";
        };
        preferences = "preferences.json";
        "no-updates" = true;
        enabled = true;
    };
    "SuperPins" = {
        id = "SuperPins";
        name = "SuperPins";
        description = "This Zen Mod enhances pinned tabs/Essentials, by making some UI/UX changes.";
        homepage = "https://github.com/CosmoCreeper/Zen-Themes/tree/main/SuperPins";
        version = "1.7.2";
        style = {
            chrome = "chrome.css";
        };
        scripts = {
            "dist/patches.uc.mjs" = {
                include = ["chrome://browser/content/browser.xhtml"];
            };
        };
        preferences = "preferences.json";
        origin = "store";
        supportsUnload = true;
        "no-updates" = true;
        enabled = true;
    };
    "NewTabIconUrlBar" = {
        id = "NewTabIconUrlBar";
        name = "Add New Tab Icon to URL Bar";
        description = "Adds a new tab icon to the URL bar.";
        homepage = "https://github.com/thestrike72/zen-browser-add-new-tab-icon-to-urlbar";
        version = "1.0.0";
        style = {
            chrome = "userChrome.css";
        };
        "no-updates" = true;
        enabled = true;
    };
    "AudioIndicatorEnhanced" = {
        id = "AudioIndicatorEnhanced";
        name = "Audio Indicator Enhanced";
        description = "Enhanced audio indicator with more polished style.";
        homepage = "https://github.com/Kaedriz/ZenMods/tree/main/AudioIndicatorEnhanced";
        version = "1.0.0";
        style = {
            chrome = "AudioIndicatorEnhanced.css";
        };
        preferences = "preferences.json";
        "no-updates" = true;
        enabled = true;
    };
    "CustomizeFontsSize" = {
        id = "CustomizeFontsSize";
        name = "Customize Fonts Size";
        description = "This Mod allows you to adjust the font size of several parts of the browser.";
        homepage = "https://github.com/joadr/zen-customize-fonts-size";
        version = "1.0.0";
        style = {
            chrome = "chrome.css";
        };
        preferences = "preferences.json";
        "no-updates" = true;
        enabled = true;
    };
    "TabTitleFix" = {
        id = "TabTitleFix";
        name = "Tab Title Fix";
        description = "Fixes tab titles.";
        homepage = "https://github.com/psu/zen-mods/tree/main/tab-title-fix";
        version = "1.0.0";
        style = {
            chrome = "chrome.css";
        };
        preferences = "preferences.json";
        "no-updates" = true;
        enabled = true;
    };
    "TrackpadAnimation" = {
        id = "TrackpadAnimation";
        name = "Trackpad Animation";
        description = "Adds trackpad scroll animations.";
        homepage = "https://github.com/Fury7425/my-zen-mods/tree/main/trackpad-animation";
        version = "1.0.0";
        style = {
            chrome = "trackpad-animation.css";
        };
        preferences = "preferences.json";
        "no-updates" = true;
        enabled = true;
    };
    "VerticalSplitTabGroups" = {
        id = "VerticalSplitTabGroups";
        name = "Vertical Split Tab Groups";
        description = "Splits tab groups vertically.";
        homepage = "https://github.com/ToBinio/zen-mods/tree/main/vertical-split-tab-groups";
        version = "1.0.0";
        style = {
            chrome = "chrome.css";
        };
        "no-updates" = true;
        enabled = true;
    };
}
