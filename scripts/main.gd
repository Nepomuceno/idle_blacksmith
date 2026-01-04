extends Control
## Main game controller - orchestrates all game systems
## Visual effects and layout management

# Preload all modular components
const GameStateClass = preload("res://scripts/data/game_state.gd")
const WeaponDataClass = preload("res://scripts/data/weapon_data.gd")
const UpgradeDataClass = preload("res://scripts/data/upgrade_data.gd")
const AchievementDataClass = preload("res://scripts/data/achievement_data.gd")
const TierDataClass = preload("res://scripts/data/tier_data.gd")
const ForgeManagerClass = preload("res://scripts/managers/forge_manager.gd")
const UpgradeManagerClass = preload("res://scripts/managers/upgrade_manager.gd")
const AchievementManagerClass = preload("res://scripts/managers/achievement_manager.gd")
const AscensionManagerClass = preload("res://scripts/managers/ascension_manager.gd")
const SaveManagerClass = preload("res://scripts/managers/save_manager.gd")
const ForgeUIClass = preload("res://scripts/ui/forge_ui.gd")
const UpgradesUIClass = preload("res://scripts/ui/upgrades_ui.gd")
const AchievementsUIClass = preload("res://scripts/ui/achievements_ui.gd")
const ShopUIClass = preload("res://scripts/ui/shop_ui.gd")

# Modular components
var game_state
var forge_manager
var upgrade_manager
var achievement_manager
var ascension_manager
var save_manager

# UI Components
var forge_ui
var upgrades_ui
var achievements_ui
var shop_ui

# Layout state
var is_wide_layout: bool = false
var current_tab: String = "forge"
var scene_ready: bool = false

# Cached node references
var forge_content_ref: Control = null
var upgrades_content_ref: Control = null
var achieve_content_ref: Control = null
var shop_content_ref: Control = null
var content_area_ref: Control = null
var gold_label_ref: Label = null
var passive_label_ref: Label = null
var ascension_label_ref: Label = null
var tab_bar_ref: Control = null
var tab_forge_ref: Button = null
var tab_upgrades_ref: Button = null
var tab_achieve_ref: Button = null
var tab_shop_ref: Button = null

# Backward compatibility references for tests
var forge_button_ref: Button = null
var ascend_button_ref: Button = null
var weapon_grid_ref: HBoxContainer = null
var main_weapon_icon_ref: TextureRect = null
var weapon_name_label_ref: Label = null
var value_label_ref: Label = null

# Wide layout containers
var wide_layout_container: HBoxContainer = null
var wide_nav_container: HBoxContainer = null

# Visual effects
var floating_texts: Array = []

# Audio
var forge_sound: AudioStreamPlayer
var upgrade_sound: AudioStreamPlayer
var ascend_sound: AudioStreamPlayer

# Timers
var passive_timer: float = 0.0
var autosave_timer: float = 0.0
var auto_forge_timer: float = 0.0
var auto_buy_timer: float = 0.0
var last_tier_effect_time: float = 0.0
const PASSIVE_TICK: float = 1.0
const AUTOSAVE_INTERVAL: float = 30.0
const AUTO_BUY_INTERVAL: float = 0.5  # Check every 0.5 seconds
const MIN_TIER_EFFECT_INTERVAL: float = 0.15  # Max ~6 effects per second


func _ready() -> void:
	_init_game_systems()
	_cache_node_references()
	_init_ui_components()
	_setup_audio()
	_connect_signals()
	_setup_tab_buttons()
	_check_layout()
	
	# Only show tab in mobile mode - wide layout handles visibility differently
	if not is_wide_layout:
		_show_tab("forge")
	
	_update_all_ui()
	
	scene_ready = true
	get_viewport().size_changed.connect(_on_window_resized)
	_check_offline_progress()


func _init_game_systems() -> void:
	game_state = GameStateClass.new()
	game_state.initialize_upgrades()
	forge_manager = ForgeManagerClass.new(game_state)
	upgrade_manager = UpgradeManagerClass.new(game_state)
	achievement_manager = AchievementManagerClass.new(game_state)
	ascension_manager = AscensionManagerClass.new(game_state)
	save_manager = SaveManagerClass.new(game_state)
	
	# Load saved game
	save_manager.load_game()
	
	# Connect theme colors to game state for ascension intensity
	ThemeColors.set_intensity_from_ascensions(game_state.total_ascensions)


func _cache_node_references() -> void:
	forge_content_ref = %ForgeContent
	upgrades_content_ref = %UpgradesContent
	achieve_content_ref = %AchieveContent
	shop_content_ref = %ShopContent
	content_area_ref = %ForgeContent.get_parent()
	
	gold_label_ref = %GoldLabel
	passive_label_ref = %PassiveLabel
	ascension_label_ref = %AscensionLabel
	
	tab_bar_ref = %TabBar
	tab_forge_ref = %TabForge
	tab_upgrades_ref = %TabUpgrades
	tab_achieve_ref = %TabAchieve
	tab_shop_ref = %TabShop
	
	# Backward compatibility references for tests
	forge_button_ref = %ForgeButton
	ascend_button_ref = %AscendButton
	weapon_grid_ref = %WeaponGrid
	main_weapon_icon_ref = %MainWeaponIcon
	weapon_name_label_ref = %WeaponNameLabel
	value_label_ref = %ValueLabel


func _init_ui_components() -> void:
	# Initialize Forge UI
	forge_ui = ForgeUIClass.new()
	forge_ui.setup(game_state, forge_manager)
	forge_ui.forge_button = %ForgeButton
	forge_ui.ascend_button = %AscendButton
	forge_ui.weapon_grid = %WeaponGrid
	forge_ui.main_weapon_icon = %MainWeaponIcon
	forge_ui.main_weapon_letter = %MainWeaponLetter
	forge_ui.weapon_name_label = %WeaponNameLabel
	forge_ui.value_label = %ValueLabel
	forge_ui.streak_label = %StreakLabel
	forge_ui.last_forged_label = %LastForgedLabel
	forge_ui.ascension_progress = %AscensionProgress
	forge_ui.connect_buttons()
	forge_ui.create_weapon_grid()
	
	# Initialize Upgrades UI
	upgrades_ui = UpgradesUIClass.new()
	upgrades_ui.setup(game_state, upgrade_manager)
	upgrades_ui.upgrades_list = %UpgradesList
	
	# Initialize Achievements UI
	achievements_ui = AchievementsUIClass.new()
	achievements_ui.setup(game_state, achievement_manager)
	achievements_ui.achieve_list = %AchieveList
	
	# Initialize Shop UI
	shop_ui = ShopUIClass.new()
	shop_ui.setup(game_state, ascension_manager, forge_manager)
	shop_ui.shop_list = %ShopList


func _connect_signals() -> void:
	# Forge UI signals
	forge_ui.forge_requested.connect(_on_forge_requested)
	forge_ui.weapon_selected.connect(_on_weapon_selected)
	forge_ui.ascend_requested.connect(_on_ascend_requested)
	
	# Upgrades UI signals
	upgrades_ui.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Achievements UI signals
	achievements_ui.rewards_claimed.connect(_on_rewards_claimed)
	
	# Shop UI signals
	shop_ui.soul_upgrade_purchased.connect(_on_soul_upgrade_purchased)
	shop_ui.weapon_upgrade_purchased.connect(_on_weapon_upgrade_purchased)
	shop_ui.reset_requested.connect(_on_reset_requested)
	
	# GameEvents signals
	GameEvents.gold_changed.connect(_on_gold_changed)
	GameEvents.achievement_unlocked.connect(_on_achievement_unlocked)
	GameEvents.ascended.connect(_on_ascended)
	GameEvents.game_completed.connect(_on_game_completed)


func _setup_audio() -> void:
	forge_sound = AudioStreamPlayer.new()
	add_child(forge_sound)
	
	upgrade_sound = AudioStreamPlayer.new()
	add_child(upgrade_sound)
	
	ascend_sound = AudioStreamPlayer.new()
	add_child(ascend_sound)
	
	_try_load_sounds()


func _try_load_sounds() -> void:
	var sounds_path = "res://assets/ui/Sounds/"
	
	if ResourceLoader.exists(sounds_path + "tap-a.ogg"):
		forge_sound.stream = load(sounds_path + "tap-a.ogg")
		forge_sound.volume_db = -5
	
	if ResourceLoader.exists(sounds_path + "click-a.ogg"):
		upgrade_sound.stream = load(sounds_path + "click-a.ogg")
		upgrade_sound.volume_db = -8
	
	if ResourceLoader.exists(sounds_path + "switch-b.ogg"):
		ascend_sound.stream = load(sounds_path + "switch-b.ogg")
		ascend_sound.volume_db = 0


func _setup_tab_buttons() -> void:
	tab_forge_ref.pressed.connect(_on_tab_pressed.bind("forge"))
	tab_upgrades_ref.pressed.connect(_on_tab_pressed.bind("upgrades"))
	tab_achieve_ref.pressed.connect(_on_tab_pressed.bind("achieve"))
	tab_shop_ref.pressed.connect(_on_tab_pressed.bind("shop"))


# ========== GAME LOOP ==========

func _process(delta: float) -> void:
	# Passive income
	if game_state.passive_income > 0:
		passive_timer += delta
		if passive_timer >= PASSIVE_TICK:
			passive_timer -= PASSIVE_TICK
			game_state.add_gold(game_state.passive_income)
	
	# Auto-forge
	var auto_rate = forge_manager.get_effective_auto_forge_rate()
	if auto_rate > 0:
		auto_forge_timer += delta
		var forge_interval = 1.0 / auto_rate
		var forges_pending = int(auto_forge_timer / forge_interval)
		
		if forges_pending <= 0:
			pass  # Nothing to do yet
		elif forges_pending <= 10:
			# Low rate: process individually for accurate tier rolling
			auto_forge_timer -= forges_pending * forge_interval
			var best_tier = 0
			var best_tier_color = Color.WHITE
			
			for i in range(forges_pending):
				var result = forge_manager.forge()
				if result["tier"] > best_tier:
					best_tier = result["tier"]
					best_tier_color = result["tier_color"]
			
			# Show effect for best tier (with cooldown)
			var current_time = Time.get_ticks_msec() / 1000.0
			if best_tier >= 2 and (current_time - last_tier_effect_time) >= MIN_TIER_EFFECT_INTERVAL:
				last_tier_effect_time = current_time
				_spawn_tier_effect(best_tier, best_tier_color)
		else:
			# High rate: use bulk calculation for performance
			auto_forge_timer -= forges_pending * forge_interval
			var result = forge_manager.bulk_forge(forges_pending)
			
			# Show effect for best tier (with cooldown)
			var current_time = Time.get_ticks_msec() / 1000.0
			if result["best_tier"] >= 2 and (current_time - last_tier_effect_time) >= MIN_TIER_EFFECT_INTERVAL:
				last_tier_effect_time = current_time
				_spawn_tier_effect(result["best_tier"], result["best_tier_color"])
	
	# Autosave
	autosave_timer += delta
	if autosave_timer >= AUTOSAVE_INTERVAL:
		autosave_timer = 0.0
		save_manager.save()
	
	# Auto-buy upgrades
	if game_state.auto_buy_enabled:
		auto_buy_timer += delta
		if auto_buy_timer >= AUTO_BUY_INTERVAL:
			auto_buy_timer = 0.0
			_do_auto_buy()
	
	# Auto-ascend
	if ascension_manager.should_auto_ascend():
		_do_auto_ascend()
	
	# Check achievements
	achievement_manager.check_all()
	
	_update_floating_texts(delta)
	forge_ui.update_display()


func _do_auto_forge() -> void:
	var result = forge_manager.forge()
	
	# Small visual feedback for auto-forge (less prominent than manual)
	if result["tier"] >= 2:
		_spawn_tier_effect(result["tier"], result["tier_color"])


func _do_auto_buy() -> void:
	# Try to buy affordable upgrades (cheapest first)
	var visible_upgrades = upgrade_manager.get_visible_upgrades()
	for upgrade_id in visible_upgrades:
		if upgrade_manager.can_afford(upgrade_id) and not upgrade_manager.is_maxed(upgrade_id):
			if upgrade_manager.purchase(upgrade_id):
				# Small visual feedback
				_spawn_floating_text("AUTO", Color(0.5, 0.8, 1.0))
				return  # Only buy one per tick to avoid lag


func _do_auto_ascend() -> void:
	var souls = ascension_manager.ascend()
	if souls > 0:
		# Quieter effect for auto-ascend
		_spawn_floating_text("ASCENDED +%d" % souls, ThemeColors.COLOR_SOULS)
		forge_ui.create_weapon_grid()
		ThemeColors.set_intensity_from_ascensions(game_state.total_ascensions)
		_update_all_ui()


# ========== EVENT HANDLERS ==========

func _on_forge_requested() -> void:
	var result = forge_manager.forge()
	
	if forge_sound.stream:
		forge_sound.pitch_scale = randf_range(0.9, 1.1)
		forge_sound.play()
	
	_spawn_floating_text("+%s" % GameStateClass.format_number(result["value"]), result["tier_color"])
	forge_ui.show_forge_result(result)
	_animate_forge_button()
	
	if result["tier"] >= 2:
		_spawn_tier_effect(result["tier"], result["tier_color"])
	
	_update_all_ui()


func _on_weapon_selected(weapon_id: String) -> void:
	forge_manager.select_weapon(weapon_id)
	forge_ui.update_display()


func _on_ascend_requested() -> void:
	var souls = ascension_manager.ascend()
	if souls > 0:
		if ascend_sound.stream:
			ascend_sound.play()
		_show_ascension_effect(souls)
		forge_ui.create_weapon_grid()
		# Update theme intensity based on new ascension count
		ThemeColors.set_intensity_from_ascensions(game_state.total_ascensions)
		_update_all_ui()


func _on_upgrade_purchased(upgrade_id: String) -> void:
	if upgrade_sound.stream:
		upgrade_sound.play()
	_spawn_floating_text("UPGRADED!", Color(0.3, 1.0, 0.3))
	_update_all_ui()


func _on_rewards_claimed(amount: float) -> void:
	_spawn_floating_text("+%s Gold!" % GameStateClass.format_number(amount), ThemeColors.GOLD_TEXT)
	if upgrade_sound.stream:
		upgrade_sound.play()
	_update_gold_display()


func _on_soul_upgrade_purchased(_upgrade_id: String) -> void:
	if ascend_sound.stream:
		ascend_sound.play()
	_spawn_floating_text("SOUL POWER!", Color(0.8, 0.5, 1))
	_update_all_ui()


func _on_weapon_upgrade_purchased(_weapon_id: String) -> void:
	if ascend_sound.stream:
		ascend_sound.play()
	_spawn_floating_text("WEAPON UPGRADED!", Color(1, 0.8, 0.3))
	_update_all_ui()


func _on_reset_requested() -> void:
	_show_reset_confirmation()


func _on_gold_changed(_new_amount: float) -> void:
	_update_gold_display()
	# In wide layout, upgrades are always visible so refresh them
	if is_wide_layout:
		upgrades_ui.refresh()


func _on_achievement_unlocked(achievement_id: String) -> void:
	var data = AchievementDataClass.get_achievement(achievement_id)
	_spawn_floating_text("Achievement: %s" % data.get("name", "???"), Color(1, 0.9, 0.3))
	if ascend_sound.stream:
		ascend_sound.play()


func _on_ascended(_souls: int) -> void:
	pass  # Handled by ascend_requested


func _on_game_completed() -> void:
	# Show the endgame credits screen
	_show_credits_screen()


# ========== TAB NAVIGATION ==========

func _on_tab_pressed(tab_name: String) -> void:
	if upgrade_sound.stream:
		upgrade_sound.play()
	_show_tab(tab_name)


func _show_tab(tab_name: String) -> void:
	current_tab = tab_name
	
	if forge_content_ref:
		forge_content_ref.visible = false
		upgrades_content_ref.visible = false
		achieve_content_ref.visible = false
		shop_content_ref.visible = false
	
	tab_forge_ref.modulate = ThemeColors.STEEL_LIGHT
	tab_upgrades_ref.modulate = ThemeColors.STEEL_LIGHT
	tab_achieve_ref.modulate = ThemeColors.STEEL_LIGHT
	tab_shop_ref.modulate = ThemeColors.STEEL_LIGHT
	
	match tab_name:
		"forge":
			if forge_content_ref:
				forge_content_ref.visible = true
			tab_forge_ref.modulate = ThemeColors.ACCENT_SECONDARY
		"upgrades":
			if upgrades_content_ref:
				upgrades_content_ref.visible = true
			tab_upgrades_ref.modulate = ThemeColors.COLOR_PASSIVE
			upgrades_ui.refresh()
		"achieve":
			if achieve_content_ref:
				achieve_content_ref.visible = true
			tab_achieve_ref.modulate = ThemeColors.GOLD_TEXT
			achievements_ui.refresh()
		"shop":
			if shop_content_ref:
				shop_content_ref.visible = true
			tab_shop_ref.modulate = ThemeColors.COLOR_SOULS
			shop_ui.refresh()


# ========== LAYOUT SYSTEM ==========

func _on_window_resized() -> void:
	if not scene_ready:
		return
	_check_layout()


func _check_layout() -> void:
	var size = get_viewport_rect().size
	var new_is_wide = size.x >= 900 and size.x > size.y
	
	if new_is_wide != is_wide_layout:
		is_wide_layout = new_is_wide
		_apply_layout()


func _apply_layout() -> void:
	if forge_content_ref == null or forge_ui.forge_button == null:
		return
	
	if is_wide_layout:
		forge_ui.forge_button.custom_minimum_size = Vector2(240, 70)
		forge_ui.forge_button.add_theme_font_size_override("font_size", 28)
		tab_bar_ref.visible = false
		forge_content_ref.visible = true
		upgrades_content_ref.visible = true
		achieve_content_ref.visible = false
		shop_content_ref.visible = false
		_setup_wide_layout()
	else:
		forge_ui.forge_button.custom_minimum_size = Vector2(280, 90)
		forge_ui.forge_button.add_theme_font_size_override("font_size", 32)
		tab_bar_ref.visible = true
		_setup_mobile_layout()
		_show_tab(current_tab)
	
	forge_ui.create_weapon_grid()


func _setup_wide_layout() -> void:
	if forge_content_ref == null or upgrades_content_ref == null:
		return
	
	if wide_layout_container == null:
		wide_layout_container = HBoxContainer.new()
		wide_layout_container.name = "WideLayoutContainer"
		wide_layout_container.add_theme_constant_override("separation", 12)
		wide_layout_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if wide_layout_container.get_parent() == content_area_ref:
		wide_layout_container.visible = true
		if wide_nav_container:
			wide_nav_container.visible = true
		achieve_content_ref.visible = false
		shop_content_ref.visible = false
		# Refresh upgrades UI when switching back to wide layout
		upgrades_ui.refresh()
		return
	
	forge_content_ref.get_parent().remove_child(forge_content_ref)
	upgrades_content_ref.get_parent().remove_child(upgrades_content_ref)
	
	forge_content_ref.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrades_content_ref.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	wide_layout_container.add_child(forge_content_ref)
	wide_layout_container.add_child(upgrades_content_ref)
	
	content_area_ref.add_child(wide_layout_container)
	
	if wide_nav_container == null:
		wide_nav_container = HBoxContainer.new()
		wide_nav_container.name = "WideNavContainer"
		wide_nav_container.alignment = BoxContainer.ALIGNMENT_END
		wide_nav_container.add_theme_constant_override("separation", 8)
		
		var achieve_btn = Button.new()
		achieve_btn.text = "ACHIEVEMENTS"
		achieve_btn.custom_minimum_size = Vector2(120, 35)
		achieve_btn.add_theme_font_size_override("font_size", 12)
		achieve_btn.pressed.connect(_on_wide_achieve_pressed)
		wide_nav_container.add_child(achieve_btn)
		
		var shop_btn = Button.new()
		shop_btn.text = "SHOP"
		shop_btn.custom_minimum_size = Vector2(80, 35)
		shop_btn.add_theme_font_size_override("font_size", 12)
		shop_btn.pressed.connect(_on_wide_shop_pressed)
		wide_nav_container.add_child(shop_btn)
	
	var header_content = gold_label_ref.get_parent()
	if wide_nav_container.get_parent() != header_content:
		header_content.add_child(wide_nav_container)
	wide_nav_container.visible = true
	
	upgrades_ui.refresh()


func _on_wide_achieve_pressed() -> void:
	if upgrade_sound.stream:
		upgrade_sound.play()
	wide_layout_container.visible = false
	achieve_content_ref.visible = true
	shop_content_ref.visible = false
	achievements_ui.refresh()
	_add_back_button_to_panel(achieve_content_ref)


func _on_wide_shop_pressed() -> void:
	if upgrade_sound.stream:
		upgrade_sound.play()
	wide_layout_container.visible = false
	achieve_content_ref.visible = false
	shop_content_ref.visible = true
	shop_ui.refresh()
	_add_back_button_to_panel(shop_content_ref)


func _add_back_button_to_panel(panel: Control) -> void:
	var existing = panel.find_child("WideBackButton", false, false)
	if existing:
		return
	
	var back_btn = Button.new()
	back_btn.name = "WideBackButton"
	back_btn.text = "< Back to Forge"
	back_btn.custom_minimum_size = Vector2(150, 40)
	back_btn.add_theme_font_size_override("font_size", 14)
	back_btn.pressed.connect(func():
		panel.visible = false
		wide_layout_container.visible = true
	)
	
	var container = panel.get_child(0)
	if container:
		var scroll = container.get_child(0)
		if scroll:
			var vbox = scroll.get_child(0)
			if vbox:
				vbox.add_child(back_btn)
				vbox.move_child(back_btn, 0)


func _setup_mobile_layout() -> void:
	if wide_layout_container == null or wide_layout_container.get_parent() == null:
		return
	
	if forge_content_ref == null or upgrades_content_ref == null:
		return
	
	if forge_content_ref.get_parent() == wide_layout_container:
		wide_layout_container.remove_child(forge_content_ref)
		content_area_ref.add_child(forge_content_ref)
	
	if upgrades_content_ref.get_parent() == wide_layout_container:
		wide_layout_container.remove_child(upgrades_content_ref)
		content_area_ref.add_child(upgrades_content_ref)
	
	content_area_ref.remove_child(wide_layout_container)
	
	if wide_nav_container:
		wide_nav_container.visible = false


# ========== UI UPDATES ==========

func _update_all_ui() -> void:
	_update_gold_display()
	forge_ui.update_display()
	
	# In wide layout, upgrades are always visible so refresh them
	if is_wide_layout:
		upgrades_ui.refresh()


func _update_gold_display() -> void:
	gold_label_ref.text = game_state.get_formatted_gold() + " Gold"
	
	var info_parts = []
	if game_state.passive_income > 0:
		info_parts.append("+%s/s" % GameStateClass.format_number(game_state.passive_income))
	
	var auto_rate = forge_manager.get_effective_auto_forge_rate()
	if auto_rate > 0:
		info_parts.append("%.1f forges/s" % auto_rate)
	
	if info_parts.size() > 0:
		passive_label_ref.text = " | ".join(info_parts)
		passive_label_ref.visible = true
	else:
		passive_label_ref.visible = false
	
	# Ascension label
	if game_state.total_ascensions > 0 or game_state.ancient_souls > 0:
		ascension_label_ref.visible = true
		ascension_label_ref.text = "%s Souls | Asc %d" % [GameStateClass.format_souls(game_state.ancient_souls), game_state.total_ascensions]
	else:
		ascension_label_ref.visible = false


# ========== VISUAL EFFECTS ==========

func _animate_forge_button() -> void:
	var tween = create_tween()
	tween.tween_property(forge_ui.forge_button, "scale", Vector2(1.1, 1.1), 0.06).set_ease(Tween.EASE_OUT)
	tween.tween_property(forge_ui.forge_button, "scale", Vector2(1.0, 1.0), 0.06).set_ease(Tween.EASE_IN)
	
	_spawn_forge_sparks()


func _spawn_forge_sparks() -> void:
	var forge_center = forge_ui.forge_button.global_position + forge_ui.forge_button.size / 2
	
	var spark_count = randi_range(5, 8)
	for i in range(spark_count):
		var spark = ColorRect.new()
		spark.size = Vector2(4, 4)
		spark.color = [
			Color(1.0, 0.8, 0.2),
			Color(1.0, 0.6, 0.1),
			Color(1.0, 0.4, 0.1),
			Color(1.0, 1.0, 0.5)
		].pick_random()
		
		var angle = randf() * TAU
		var distance = randf_range(30, 60)
		spark.position = forge_center + Vector2(cos(angle), sin(angle)) * 20
		
		add_child(spark)
		
		var target_pos = forge_center + Vector2(cos(angle), sin(angle)) * distance + Vector2(0, randf_range(-30, 10))
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "position", target_pos, 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_property(spark, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
		tween.tween_property(spark, "size", Vector2(1, 1), 0.4)
		tween.set_parallel(false)
		tween.tween_callback(spark.queue_free)


func _spawn_tier_effect(tier: int, color: Color) -> void:
	var forge_center = forge_ui.forge_button.global_position + forge_ui.forge_button.size / 2
	
	# Reduce particles at high forge rates to prevent visual overload
	var auto_rate = forge_manager.get_effective_auto_forge_rate()
	var particle_scale = 1.0
	if auto_rate > 10:
		particle_scale = clampf(10.0 / auto_rate, 0.2, 1.0)
	
	var base_particle_count = [0, 0, 8, 15, 25][tier]
	var particle_count = int(base_particle_count * particle_scale)
	particle_count = maxi(particle_count, 2) if base_particle_count > 0 else 0
	
	for i in range(particle_count):
		var particle = ColorRect.new()
		var size_val = randf_range(3, 8) if tier >= 4 else randf_range(2, 5)
		particle.size = Vector2(size_val, size_val)
		
		if randf() > 0.5:
			particle.color = color
		else:
			particle.color = Color(1.0, 1.0, 0.8)
		
		particle.position = forge_center
		add_child(particle)
		
		var angle = randf() * TAU
		var speed = randf_range(80, 180) if tier >= 4 else randf_range(50, 120)
		var target_pos = forge_center + Vector2(cos(angle), sin(angle)) * speed
		target_pos.y -= randf_range(20, 60)
		
		var duration = randf_range(0.5, 0.9)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target_pos, duration).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
		tween.tween_property(particle, "rotation", randf_range(-3, 3), duration)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)
	
	# Only flash screen if not in rapid fire mode
	if tier >= 4 and auto_rate < 20:
		_flash_screen(color)


func _flash_screen(color: Color) -> void:
	var flash = ColorRect.new()
	flash.color = Color(color.r, color.g, color.b, 0.4)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_callback(flash.queue_free)


func _spawn_floating_text(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var forge_pos = forge_ui.forge_button.global_position + forge_ui.forge_button.size / 2
	label.global_position = forge_pos + Vector2(randf_range(-40, 40), -30)
	
	add_child(label)
	floating_texts.append({
		"label": label,
		"velocity": Vector2(0, -100),
		"lifetime": 1.2,
		"age": 0.0
	})


func _update_floating_texts(delta: float) -> void:
	var to_remove = []
	for ft in floating_texts:
		ft["age"] += delta
		ft["label"].position += ft["velocity"] * delta
		ft["label"].modulate.a = 1.0 - (ft["age"] / ft["lifetime"])
		
		if ft["age"] >= ft["lifetime"]:
			ft["label"].queue_free()
			to_remove.append(ft)
	
	for ft in to_remove:
		floating_texts.erase(ft)


func _show_ascension_effect(souls: int) -> void:
	var flash = ColorRect.new()
	flash.color = Color(1, 0.9, 0.5, 0.8)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 1.0)
	tween.tween_callback(flash.queue_free)
	
	_spawn_floating_text("ASCENDED! +%d SOULS" % souls, Color(1, 0.8, 0.2))


# ========== OFFLINE PROGRESS ==========

func _check_offline_progress() -> void:
	var offline = save_manager.calculate_offline_progress()
	if offline["gold"] > 0:
		_show_offline_popup(offline["gold"], offline["seconds"])


func _show_offline_popup(gold_earned: float, seconds_away: float) -> void:
	var overlay = ColorRect.new()
	overlay.name = "OfflineOverlay"
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 200)
	panel.pivot_offset = Vector2(150, 100)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.15, 0.98)
	style.border_color = Color(1, 0.7, 0.2, 0.9)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	
	var title = Label.new()
	title.text = "Welcome Back!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	vbox.add_child(title)
	
	var hours = int(seconds_away / 3600)
	var minutes = int(fmod(seconds_away, 3600) / 60)
	var time_text = ""
	if hours > 0:
		time_text = "%dh %dm" % [hours, minutes]
	else:
		time_text = "%d minutes" % minutes
	
	var time_label = Label.new()
	time_label.text = "You were away for %s" % time_text
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 14)
	time_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(time_label)
	
	var gold_label = Label.new()
	gold_label.text = "+%s Gold" % GameStateClass.format_number(gold_earned)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	vbox.add_child(gold_label)
	
	var collect_btn = Button.new()
	collect_btn.text = "Collect"
	collect_btn.custom_minimum_size = Vector2(150, 50)
	collect_btn.add_theme_font_size_override("font_size", 18)
	collect_btn.pressed.connect(func():
		save_manager.apply_offline_progress(gold_earned)
		_update_gold_display()
		if ascend_sound.stream:
			ascend_sound.play()
		overlay.queue_free()
	)
	vbox.add_child(collect_btn)
	
	panel.add_child(vbox)
	overlay.add_child(panel)
	panel.position = (get_viewport_rect().size - panel.custom_minimum_size) / 2
	
	panel.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


# ========== RESET ==========

func _show_reset_confirmation() -> void:
	var overlay = ColorRect.new()
	overlay.name = "ResetOverlay"
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 180)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.1, 0.1, 0.98)
	style.border_color = Color(1, 0.3, 0.3, 0.9)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	
	var title = Label.new()
	title.text = "Reset Progress?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	vbox.add_child(title)
	
	var warning = Label.new()
	warning.text = "This will delete ALL progress!\nThis cannot be undone."
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_font_size_override("font_size", 14)
	warning.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(warning)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(100, 40)
	cancel_btn.pressed.connect(func(): overlay.queue_free())
	hbox.add_child(cancel_btn)
	
	var confirm_btn = Button.new()
	confirm_btn.text = "Reset"
	confirm_btn.custom_minimum_size = Vector2(100, 40)
	confirm_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	confirm_btn.pressed.connect(func():
		save_manager.reset_all()
		overlay.queue_free()
		forge_ui.create_weapon_grid()
		shop_ui.refresh()
		_update_all_ui()
		_spawn_floating_text("PROGRESS RESET", Color(1, 0.5, 0.5))
	)
	hbox.add_child(confirm_btn)
	
	vbox.add_child(hbox)
	panel.add_child(vbox)
	overlay.add_child(panel)
	panel.position = (get_viewport_rect().size - panel.custom_minimum_size) / 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_manager.save()
		get_tree().quit()


# ========== ENDGAME CREDITS ==========

func _show_credits_screen() -> void:
	var overlay = ColorRect.new()
	overlay.name = "CreditsOverlay"
	overlay.color = Color(0, 0, 0, 0.0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	# Fade in overlay
	var fade_tween = create_tween()
	fade_tween.tween_property(overlay, "color:a", 0.95, 1.5)
	
	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 500)
	panel.pivot_offset = Vector2(200, 250)
	panel.modulate.a = 0.0
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.03, 0.08, 0.98)
	style.border_color = Color(1, 0.8, 0.2, 1)
	style.set_border_width_all(4)
	style.set_corner_radius_all(20)
	style.shadow_color = Color(1, 0.7, 0.2, 0.5)
	style.shadow_size = 20
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 30
	style.content_margin_bottom = 30
	panel.add_theme_stylebox_override("panel", style)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(340, 440)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Title
	var title = Label.new()
	title.text = "COSMIC MASTERY ACHIEVED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "You have mastered the art of forging\nand transcended mortal limits."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.7, 0.9))
	vbox.add_child(subtitle)
	
	# Stats section
	var stats_title = Label.new()
	stats_title.text = "YOUR LEGACY"
	stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_title.add_theme_font_size_override("font_size", 18)
	stats_title.add_theme_color_override("font_color", ThemeColors.COLOR_SOULS)
	vbox.add_child(stats_title)
	
	var stats_text = Label.new()
	stats_text.text = """Total Ascensions: %d
Ancient Souls Collected: %s
Weapons Forged: %s
Lifetime Gold: %s""" % [
		game_state.total_ascensions,
		GameStateClass.format_souls(game_state.ancient_souls),
		GameStateClass.format_number(float(game_state.total_items_forged)),
		GameStateClass.format_number(game_state.lifetime_gold + game_state.total_gold_earned)
	]
	stats_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_text.add_theme_font_size_override("font_size", 14)
	stats_text.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(stats_text)
	
	# Lore text
	var lore = Label.new()
	lore.text = """The cosmic forge burns eternal.
From a simple anvil in Aethermoor,
you have risen to shape reality itself.

The gods themselves now seek your work.
Stars are forged in your flames.
Legends are but sparks from your hammer.

Yet the forge never rests...
There are always more weapons to create,
more power to accumulate,
more realities to shape."""
	lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore.add_theme_font_size_override("font_size", 12)
	lore.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lore)
	
	# Credits
	var credits_title = Label.new()
	credits_title.text = "CREATED BY"
	credits_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_title.add_theme_font_size_override("font_size", 16)
	credits_title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	vbox.add_child(credits_title)
	
	var credits = Label.new()
	credits.text = "Gabriel Nepomuceno\n\nThank you for playing!"
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size", 14)
	credits.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(credits)
	
	# Continue button
	var continue_btn = Button.new()
	continue_btn.text = "Continue Playing"
	continue_btn.custom_minimum_size = Vector2(180, 50)
	continue_btn.add_theme_font_size_override("font_size", 16)
	continue_btn.pressed.connect(func():
		var close_tween = create_tween()
		close_tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
		close_tween.tween_callback(overlay.queue_free)
	)
	vbox.add_child(continue_btn)
	
	scroll.add_child(vbox)
	panel.add_child(scroll)
	overlay.add_child(panel)
	panel.position = (get_viewport_rect().size - panel.custom_minimum_size) / 2
	
	# Animate panel appearing
	await get_tree().create_timer(0.5).timeout
	var panel_tween = create_tween()
	panel_tween.tween_property(panel, "modulate:a", 1.0, 1.0)
	panel_tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.5).from(Vector2(0.8, 0.8)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
