extends CanvasLayer

signal fishing_finished(success: bool, fish: FishType, value: int)

@export var fish: FishType
@export var rod: RodType

@onready var root_ui: Control = %Control
@onready var catch_area: Control = %CatchArea
@onready var bar_track: Control = %BarTrack
@onready var catch_bar: ColorRect = %CatchBar
@onready var fish_icon: TextureRect = %FishIcon
@onready var progress: ProgressBar = %Progress
@onready var label_name: Label = %LabelFishName
@onready var sfx_hook: AudioStreamPlayer = %SFXH
@onready var sfx_catch: AudioStreamPlayer = %SFXC
@onready var sfx_fail: AudioStreamPlayer = %SFXF
@onready var burst: GPUParticles2D = %ParticlesBurst

const BASE_BAR_HEIGHT := 20.0
const BASE_HOOK_WINDOW := 0.6
const BASE_ESCAPE_DRAIN := 22.0
const PROGRESS_GAIN := 28.0
const DURATION := 5.0

enum STATE { CASTING, BITE, HOOK, PLAY, END}

var _state: STATE = STATE.CASTING
var _elapsed: float = 0.0
var _duration: float = 0.0
var _bite_timer: float
var _hook_window: float
var _bar_h: float
var _bar_pos: float = 0.0
var _bar_vel: float = 0.0
var _fish_pos: float = 0.5
var _fish_vel: float = 0.0
var _progress_val: float = 0.0
var _fish_seed: float
