extends GutTest
## Integration tests for main scene
## Tests cover: scene loading, UI initialization, and basic interactions

var main_scene: Node


func before_each() -> void:
	# Load the main scene
	var scene = load("res://scenes/main.tscn")
	main_scene = scene.instantiate()
	add_child(main_scene)
	# Wait for _ready to complete
	await get_tree().process_frame
	# Reset game state for consistent test state
	main_scene.save_manager.reset_all()
	await get_tree().process_frame


func after_each() -> void:
	if main_scene:
		# Clean up to avoid orphans
		if main_scene.game_state:
			main_scene.game_state.queue_free()
		main_scene.queue_free()
		main_scene = null
	# Wait for cleanup
	await get_tree().process_frame


# ========== SCENE LOADING TESTS ==========

func test_main_scene_loads() -> void:
	assert_not_null(main_scene, "Main scene should load successfully")


func test_game_state_initialized() -> void:
	var gs = main_scene.game_state
	assert_not_null(gs, "GameState should be initialized")


# ========== UI ELEMENT TESTS ==========

func test_forge_button_exists() -> void:
	var forge_button = main_scene.forge_button_ref
	assert_not_null(forge_button, "Forge button should exist")
	assert_is(forge_button, Button, "Forge button should be a Button")


func test_gold_label_exists() -> void:
	var gold_label = main_scene.gold_label_ref
	assert_not_null(gold_label, "Gold label should exist")
	assert_is(gold_label, Label, "Gold label should be a Label")


func test_tab_buttons_exist() -> void:
	assert_not_null(main_scene.tab_forge_ref, "Forge tab should exist")
	assert_not_null(main_scene.tab_upgrades_ref, "Upgrades tab should exist")
	assert_not_null(main_scene.tab_achieve_ref, "Achievements tab should exist")
	assert_not_null(main_scene.tab_shop_ref, "Shop tab should exist")


func test_content_panels_exist() -> void:
	assert_not_null(main_scene.forge_content_ref, "Forge content should exist")
	assert_not_null(main_scene.upgrades_content_ref, "Upgrades content should exist")
	assert_not_null(main_scene.achieve_content_ref, "Achievements content should exist")
	assert_not_null(main_scene.shop_content_ref, "Shop content should exist")


func test_weapon_display_elements_exist() -> void:
	assert_not_null(main_scene.main_weapon_icon_ref, "Weapon icon should exist")
	assert_not_null(main_scene.weapon_name_label_ref, "Weapon name label should exist")
	assert_not_null(main_scene.value_label_ref, "Value label should exist")


# ========== INITIAL STATE TESTS ==========

func test_initial_gold_display_shows_zero() -> void:
	assert_eq(main_scene.game_state.gold, 0.0, "Game state gold should be 0 initially")


func test_forge_content_visible_initially() -> void:
	assert_true(main_scene.forge_content_ref.visible, "Forge content should be visible initially")


func test_ascend_button_hidden_initially() -> void:
	var ascend_button = main_scene.ascend_button_ref
	assert_false(ascend_button.visible, "Ascend button should be hidden initially")


# ========== FORGE INTERACTION TESTS ==========

func test_forge_increases_gold() -> void:
	var initial_gold = main_scene.game_state.gold
	# Simulate forge press via the handler
	main_scene._on_forge_requested()
	await get_tree().process_frame
	assert_gt(main_scene.game_state.gold, initial_gold, "Gold should increase after forging")


func test_forge_increments_items_forged() -> void:
	var initial_forged = main_scene.game_state.total_items_forged
	main_scene._on_forge_requested()
	await get_tree().process_frame
	assert_eq(main_scene.game_state.total_items_forged, initial_forged + 1, "Items forged should increment")


func test_forge_updates_gold_display() -> void:
	main_scene._on_forge_requested()
	await get_tree().process_frame
	var gold_label = main_scene.gold_label_ref
	# After forging, gold should be > 0, so label shouldn't just say "0 Gold"
	assert_false(gold_label.text == "0 Gold", "Gold display should update after forging")


# ========== TAB NAVIGATION TESTS ==========

func test_show_upgrades_tab() -> void:
	main_scene._show_tab("upgrades")
	await get_tree().process_frame
	assert_true(main_scene.upgrades_content_ref.visible, "Upgrades content should be visible")
	assert_false(main_scene.forge_content_ref.visible, "Forge content should be hidden")


func test_show_achievements_tab() -> void:
	main_scene._show_tab("achieve")
	await get_tree().process_frame
	assert_true(main_scene.achieve_content_ref.visible, "Achievements content should be visible")


func test_show_shop_tab() -> void:
	main_scene._show_tab("shop")
	await get_tree().process_frame
	assert_true(main_scene.shop_content_ref.visible, "Shop content should be visible")


func test_return_to_forge_tab() -> void:
	main_scene._show_tab("upgrades")
	await get_tree().process_frame
	main_scene._show_tab("forge")
	await get_tree().process_frame
	assert_true(main_scene.forge_content_ref.visible, "Forge content should be visible again")


# ========== UPGRADE PURCHASE TESTS ==========

func test_purchase_upgrade_through_manager() -> void:
	# Give enough gold to purchase
	main_scene.game_state.gold = 100.0
	main_scene.game_state.highest_gold_ever = 100.0
	
	var initial_level = main_scene.game_state.upgrades.get("better_anvil", 0)
	var result = main_scene.upgrade_manager.purchase("better_anvil")
	
	assert_true(result, "Purchase should succeed")
	assert_eq(main_scene.game_state.upgrades["better_anvil"], initial_level + 1, "Upgrade should be purchased")


# ========== WEAPON SELECTION TESTS ==========

func test_weapon_grid_populated() -> void:
	var weapon_grid = main_scene.weapon_grid_ref
	assert_gt(weapon_grid.get_child_count(), 0, "Weapon grid should have children")


func test_selected_weapon_displayed() -> void:
	# Check the game state selected weapon is sword
	assert_eq(main_scene.game_state.selected_weapon, "sword", "Initial weapon should be sword")


# ========== AUDIO ELEMENTS TESTS ==========

func test_audio_players_exist() -> void:
	assert_not_null(main_scene.forge_sound, "Forge sound player should exist")
	assert_not_null(main_scene.upgrade_sound, "Upgrade sound player should exist")
	assert_not_null(main_scene.ascend_sound, "Ascend sound player should exist")
