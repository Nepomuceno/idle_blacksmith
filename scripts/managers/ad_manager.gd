## Ad Manager for Idle Blacksmith
## This manager handles interstitial ads with non-intrusive timing.
## Currently DISABLED by default - set enabled = true when ready to enable ads.
##
## Requires: AdMob plugin for Godot 4.x
## Install from: https://github.com/poing-studios/Godot-AdMob-Android-iOS
##
## Setup:
## 1. Install the AdMob plugin
## 2. Create an AdMob account and get your App ID and Ad Unit IDs
## 3. Update the AD_UNIT_* constants below with your IDs
## 4. Set enabled = true
## 5. Add this as an autoload: Project > Project Settings > Autoload

extends Node

## ============================================
## CONFIGURATION
## ============================================

## Master switch to enable/disable all ads
const ENABLED: bool = false

## Minimum time between interstitial ads (in seconds)
const MIN_AD_INTERVAL: float = 180.0  # 3 minutes

## Minimum forges between interstitial ads
const MIN_FORGES_BETWEEN_ADS: int = 50

## Show ad after returning from background (if enough time passed)
const SHOW_AD_ON_RESUME: bool = true
const MIN_BACKGROUND_TIME_FOR_AD: float = 60.0  # 1 minute

## ============================================
## AD UNIT IDs (Replace with your own!)
## ============================================

# Test IDs - Replace with production IDs before release!
const AD_UNIT_INTERSTITIAL_ANDROID: String = "ca-app-pub-3940256099942544/1033173712"  # Test ID
const AD_UNIT_INTERSTITIAL_IOS: String = "ca-app-pub-3940256099942544/4411468910"  # Test ID

# AdMob App IDs (set in export settings, not here)
# Android: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
# iOS: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX

## ============================================
## INTERNAL STATE
## ============================================

var _interstitial_ad: Object = null
var _last_ad_time: float = 0.0
var _forges_since_last_ad: int = 0
var _background_start_time: float = 0.0
var _is_ad_ready: bool = false
var _is_mobile: bool = false

## Signals
signal ad_started
signal ad_finished
signal ad_failed(error: String)


func _ready() -> void:
	_is_mobile = OS.get_name() in ["Android", "iOS"]
	
	if not ENABLED:
		print("[AdManager] Ads are DISABLED")
		return
	
	if not _is_mobile:
		print("[AdManager] Not on mobile platform, ads disabled")
		return
	
	_initialize_admob()
	_connect_signals()


func _initialize_admob() -> void:
	# Check if AdMob plugin is available
	if not _has_admob_plugin():
		push_warning("[AdManager] AdMob plugin not found. Install from: https://github.com/poing-studios/Godot-AdMob-Android-iOS")
		return
	
	print("[AdManager] Initializing AdMob...")
	
	# Initialize the AdMob SDK
	# Note: Actual initialization depends on the plugin version
	# This is a placeholder for the actual plugin API
	_load_interstitial()


func _has_admob_plugin() -> bool:
	# Check for AdMob singleton (plugin-dependent)
	return Engine.has_singleton("AdMob") or Engine.has_singleton("MobileAds")


func _get_interstitial_unit_id() -> String:
	match OS.get_name():
		"Android":
			return AD_UNIT_INTERSTITIAL_ANDROID
		"iOS":
			return AD_UNIT_INTERSTITIAL_IOS
		_:
			return ""


func _load_interstitial() -> void:
	if not _has_admob_plugin():
		return
	
	var unit_id := _get_interstitial_unit_id()
	if unit_id.is_empty():
		return
	
	# Placeholder for actual plugin API
	# Example for poing-studios plugin:
	# MobileAds.load_interstitial(unit_id)
	print("[AdManager] Loading interstitial ad...")


func _connect_signals() -> void:
	# Connect to game events for tracking forge count
	if GameEvents:
		if GameEvents.has_signal("weapon_forged"):
			GameEvents.weapon_forged.connect(_on_weapon_forged)
	
	# Connect to app lifecycle
	get_tree().root.connect("focus_entered", _on_app_resumed)
	get_tree().root.connect("focus_exited", _on_app_paused)


## ============================================
## PUBLIC API
## ============================================

## Call this to potentially show an interstitial ad.
## The ad will only show if all conditions are met:
## - Ads are enabled
## - On mobile platform
## - Enough time has passed since last ad
## - Enough forges have occurred since last ad
## - An ad is loaded and ready
func try_show_interstitial() -> bool:
	if not _can_show_ad():
		return false
	
	return _show_interstitial()


## Force show an interstitial (use sparingly)
func force_show_interstitial() -> bool:
	if not ENABLED or not _is_mobile or not _is_ad_ready:
		return false
	
	return _show_interstitial()


## Check if an interstitial ad is ready to show
func is_interstitial_ready() -> bool:
	return _is_ad_ready


## Reset the forge counter (call after showing an ad or at session start)
func reset_forge_counter() -> void:
	_forges_since_last_ad = 0


## Get current forge count since last ad
func get_forges_since_last_ad() -> int:
	return _forges_since_last_ad


## ============================================
## INTERNAL METHODS
## ============================================

func _can_show_ad() -> bool:
	if not ENABLED:
		return false
	
	if not _is_mobile:
		return false
	
	if not _is_ad_ready:
		return false
	
	# Check time since last ad
	var current_time := Time.get_ticks_msec() / 1000.0
	if current_time - _last_ad_time < MIN_AD_INTERVAL:
		return false
	
	# Check forge count
	if _forges_since_last_ad < MIN_FORGES_BETWEEN_ADS:
		return false
	
	return true


func _show_interstitial() -> bool:
	if not _has_admob_plugin():
		return false
	
	print("[AdManager] Showing interstitial ad...")
	ad_started.emit()
	
	# Placeholder for actual plugin API
	# Example: MobileAds.show_interstitial()
	
	# Update state
	_last_ad_time = Time.get_ticks_msec() / 1000.0
	_forges_since_last_ad = 0
	_is_ad_ready = false
	
	# Preload next ad
	_load_interstitial()
	
	return true


## ============================================
## EVENT HANDLERS
## ============================================

func _on_weapon_forged() -> void:
	_forges_since_last_ad += 1


func _on_app_paused() -> void:
	_background_start_time = Time.get_ticks_msec() / 1000.0


func _on_app_resumed() -> void:
	if not SHOW_AD_ON_RESUME:
		return
	
	var background_time := (Time.get_ticks_msec() / 1000.0) - _background_start_time
	if background_time >= MIN_BACKGROUND_TIME_FOR_AD:
		# User was away for a while, good time for an ad
		try_show_interstitial()


## AdMob callback handlers (connect these to the plugin's signals)
func _on_interstitial_loaded() -> void:
	print("[AdManager] Interstitial ad loaded")
	_is_ad_ready = true


func _on_interstitial_failed_to_load(error_code: int) -> void:
	push_warning("[AdManager] Failed to load interstitial: %d" % error_code)
	_is_ad_ready = false
	ad_failed.emit("Failed to load: %d" % error_code)
	
	# Retry after delay
	await get_tree().create_timer(30.0).timeout
	_load_interstitial()


func _on_interstitial_closed() -> void:
	print("[AdManager] Interstitial ad closed")
	ad_finished.emit()
	
	# Preload next ad
	_load_interstitial()


func _on_interstitial_clicked() -> void:
	print("[AdManager] Interstitial ad clicked")
