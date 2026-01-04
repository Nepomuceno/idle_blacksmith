extends Node
## Centralized theme color definitions for Idle Blacksmith
## Colors blend the icon aesthetic with the game UI
## Intensity increases with ascension count for visual progression

# === BASE COLORS (Subtle - 0 Ascensions) ===

# Backgrounds - Navy-black to match icon
const BG_MAIN := Color(0.031, 0.031, 0.063)  # #080810 - Main background
const BG_PANEL := Color(0.059, 0.063, 0.094)  # #0F1018 - Panel backgrounds
const BG_HEADER := Color(0.071, 0.078, 0.110)  # #12141C - Header background
const BG_TAB_BAR := Color(0.078, 0.086, 0.118)  # #14161E - Tab bar background
const BG_FORGE_PANEL := Color(0.055, 0.043, 0.035)  # #0E0B09 - Forge area (warm tint)

# Accents - Vibrant forge orange from icon
const ACCENT_PRIMARY := Color(0.902, 0.333, 0.0)  # #E65500 - Primary buttons/highlights
const ACCENT_SECONDARY := Color(1.0, 0.467, 0.133)  # #FF7722 - Secondary/borders
const ACCENT_GLOW := Color(1.0, 0.333, 0.0)  # #FF5500 - Glow effects
const ACCENT_EMBER := Color(1.0, 0.533, 0.2)  # #FF8833 - Ember particles

# Gold/Text
const GOLD_TEXT := Color(1.0, 0.8, 0.2)  # #FFCC33 - Gold text (icon gold)
const GOLD_BRIGHT := Color(1.0, 0.85, 0.3)  # #FFD94D - Bright gold for emphasis
const GOLD_DIM := Color(0.9, 0.7, 0.25)  # #E6B340 - Dimmed gold

# Metallic accents from icon
const STEEL_LIGHT := Color(0.533, 0.573, 0.635)  # #8892A2 - Light steel
const STEEL_DARK := Color(0.38, 0.42, 0.48)  # #616B7A - Dark steel
const IRON_ANVIL := Color(0.227, 0.227, 0.29)  # #3A3A4A - Anvil dark iron

# Income type colors
const COLOR_PASSIVE := Color(0.4, 1.0, 0.4)  # Green for passive income
const COLOR_SOULS := Color(0.8, 0.5, 1.0)  # Purple for souls

# Border colors
const BORDER_GOLD := Color(1.0, 0.7, 0.2, 0.8)  # Golden borders
const BORDER_STEEL := Color(0.5, 0.55, 0.6, 0.6)  # Steel borders
const BORDER_ORANGE := Color(1.0, 0.5, 0.2, 0.8)  # Orange borders

# === BOLD COLORS (High Ascension) ===
# These are the more intense versions used at high ascension counts

const BOLD_BG_MAIN := Color(0.04, 0.035, 0.07)  # Slightly more saturated
const BOLD_BG_PANEL := Color(0.07, 0.065, 0.11)
const BOLD_ACCENT_PRIMARY := Color(1.0, 0.4, 0.05)  # Brighter orange
const BOLD_ACCENT_SECONDARY := Color(1.0, 0.55, 0.15)
const BOLD_ACCENT_GLOW := Color(1.0, 0.4, 0.0)
const BOLD_GOLD_TEXT := Color(1.0, 0.85, 0.25)
const BOLD_BORDER_GLOW := Color(1.0, 0.6, 0.1, 1.0)  # More intense glow

# === INTENSITY SCALING ===
# Ascensions needed to reach full bold intensity
const MAX_INTENSITY_ASCENSIONS := 50

# Current intensity (0.0 = subtle, 1.0 = bold)
var intensity: float = 0.0

# Reference to game state for ascension count
var _game_state: Node = null


func _ready() -> void:
	# Try to connect to GameEvents for ascension updates
	if GameEvents:
		GameEvents.ascended.connect(_on_ascended)


func set_game_state(state: Node) -> void:
	_game_state = state
	_update_intensity()


func _on_ascended(_souls: int) -> void:
	_update_intensity()


func _update_intensity() -> void:
	if _game_state and _game_state.has_method("get"):
		var ascensions = _game_state.total_ascensions if _game_state.get("total_ascensions") else 0
		intensity = clampf(float(ascensions) / MAX_INTENSITY_ASCENSIONS, 0.0, 1.0)
	else:
		intensity = 0.0


func set_intensity_from_ascensions(ascension_count: int) -> void:
	intensity = clampf(float(ascension_count) / MAX_INTENSITY_ASCENSIONS, 0.0, 1.0)


# === COLOR GETTERS (Interpolated by intensity) ===

func get_bg_main() -> Color:
	return BG_MAIN.lerp(BOLD_BG_MAIN, intensity)


func get_bg_panel() -> Color:
	return BG_PANEL.lerp(BOLD_BG_PANEL, intensity)


func get_accent_primary() -> Color:
	return ACCENT_PRIMARY.lerp(BOLD_ACCENT_PRIMARY, intensity)


func get_accent_secondary() -> Color:
	return ACCENT_SECONDARY.lerp(BOLD_ACCENT_SECONDARY, intensity)


func get_accent_glow() -> Color:
	return ACCENT_GLOW.lerp(BOLD_ACCENT_GLOW, intensity)


func get_gold_text() -> Color:
	return GOLD_TEXT.lerp(BOLD_GOLD_TEXT, intensity)


func get_border_glow() -> Color:
	return BORDER_GOLD.lerp(BOLD_BORDER_GLOW, intensity)


# === STATIC HELPERS FOR COMMON PATTERNS ===

static func create_panel_stylebox(bg_color: Color, border_color: Color = Color.TRANSPARENT, border_width: int = 0, corner_radius: int = 8) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	
	if border_color.a > 0:
		style.border_color = border_color
		style.border_width_left = border_width
		style.border_width_right = border_width
		style.border_width_top = border_width
		style.border_width_bottom = border_width
	
	return style


static func create_button_stylebox(bg_color: Color, border_color: Color, pressed: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	if pressed:
		style.bg_color = bg_color.darkened(0.2)
	else:
		style.bg_color = bg_color
	
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	return style


# === FORGE BUTTON STYLES ===

func get_forge_button_normal() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_accent_primary()
	style.border_color = get_accent_secondary()
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	# Add glow effect at higher intensity
	if intensity > 0.3:
		style.shadow_color = get_accent_glow()
		style.shadow_color.a = intensity * 0.5
		style.shadow_size = int(4 + intensity * 8)
	
	return style


func get_forge_button_pressed() -> StyleBoxFlat:
	var style = get_forge_button_normal()
	style.bg_color = style.bg_color.darkened(0.15)
	return style


func get_forge_button_hover() -> StyleBoxFlat:
	var style = get_forge_button_normal()
	style.bg_color = style.bg_color.lightened(0.1)
	style.border_color = GOLD_BRIGHT
	return style


# === TAB BUTTON STYLES ===

func get_tab_normal() -> StyleBoxFlat:
	return create_panel_stylebox(
		BG_PANEL.darkened(0.1),
		BORDER_STEEL,
		1,
		6
	)


func get_tab_active() -> StyleBoxFlat:
	var style = create_panel_stylebox(
		get_accent_primary().darkened(0.3),
		get_accent_secondary(),
		2,
		6
	)
	return style


# === CARD STYLES ===

func get_upgrade_card_stylebox(affordable: bool, maxed: bool = false) -> StyleBoxFlat:
	var bg: Color
	var border: Color
	
	if maxed:
		bg = Color(0.15, 0.18, 0.12)  # Green tint for maxed
		border = Color(0.4, 0.7, 0.3, 0.6)
	elif affordable:
		bg = BG_PANEL.lightened(0.05)
		border = get_accent_secondary()
		border.a = 0.7
	else:
		bg = BG_PANEL.darkened(0.1)
		border = STEEL_DARK
		border.a = 0.4
	
	return create_panel_stylebox(bg, border, 2, 8)


func get_achievement_card_stylebox(unlocked: bool) -> StyleBoxFlat:
	if unlocked:
		return create_panel_stylebox(
			Color(0.12, 0.1, 0.06),  # Warm unlocked
			GOLD_DIM,
			2,
			8
		)
	else:
		return create_panel_stylebox(
			BG_PANEL.darkened(0.2),
			STEEL_DARK,
			1,
			8
		)


# === HEADER STYLES ===

func get_header_stylebox() -> StyleBoxFlat:
	var style = create_panel_stylebox(
		BG_HEADER,
		get_border_glow(),
		2,
		0
	)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style
