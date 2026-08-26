# 自定义 G-code Macro 参考

本文以 `printer_base.cfg` 的当前 include 图为准，记录本仓库实际加载的
`[gcode_macro]`。不包含外部 `mainsail.cfg`、KTCC 插件内部命令、
`[delayed_gcode]` 回调以及未加载的 T3 工具定义。

“原始命令”列只在 macro 使用 `rename_existing` 覆盖已有命令时填写。
该名称是在自定义 macro 内调用原始实现的别名。以下划线开头的命令是内部
状态容器或辅助命令，通常不应由操作员直接调用。

“外部调用者”只记录 Mainsail 或 KTCC 对该 macro 的入站引用：即外部组件
会按这个名字读取或执行它。macro 主动调用 KTCC、被其他本地 macro 调用、
由切片器调用或可在 Mainsail 控制台手动执行，都不在此列标记。`—` 表示没有
发现来自 Mainsail 或 KTCC 的直接入站引用。

当前识别到 2 个 Mainsail 入站接口和 5 个 KTCC 入站接口。特别地，KTCC
源码虽然出现 `SET_RETRACTION` 和 `SET_PRESSURE_ADVANCE` 字符串，但它直接
调用 Klipper 的 Python handler，并不会经过本表中的同名 macro，因此这两行
不标记为“被 KTCC 调用”。

## 配置与内部状态

| 命令 | 原始命令 | 功能 | 外部调用者 | 定义文件 |
| --- | --- | --- | --- | --- |
| `_SETTINGS` | — | 保存 adaptive mesh、adaptive purge、换刀检测、位置恢复等全局开关。 | — | `printer_base.cfg` |
| `_CLIENT_VARIABLE` | — | 保存 Mainsail 客户端暂停、取消和停靠相关参数。 | Mainsail（读取配置） | `settings/mainsail_client.cfg` |
| `_FILAMENT_SETTINGS` | — | 保存 T0–T3 各自的装料、退料、冷拉长度与速度限制。 | — | `macros/filament.cfg` |

## 换刀、工具与耦合器

| 命令 | 原始命令 | 功能 | 外部调用者 | 定义文件 |
| --- | --- | --- | --- | --- |
| `_TOOLCHANGE_RETRACT` | — | 卸载工具前按 melt zone 长度分段回抽耗材。 | — | `tools/toolgroup.cfg` |
| `_TOOLCHANGE_PRIME` | — | 装载工具后按 melt zone 长度分段恢复耗材。 | — | `tools/toolgroup.cfg` |
| `_TOOLCHANGE_DROPOFF` | — | 保存或清除打印位置、复位 offset、回抽、停靠、解锁并将工具切到待机温度。 | KTCC（`dropoff_gcode`） | `tools/toolgroup.cfg` |
| `_TOOLCHANGE_PICKUP` | — | 解锁耦合器、拾取并锁定工具、等待温度、prime、应用工具 offset/温度补偿并按需恢复位置。 | KTCC（`pickup_gcode`） | `tools/toolgroup.cfg` |
| `T0` | — | 通过 KTCC 选择 T0。 | — | `tools/macros.cfg` |
| `T1` | — | 通过 KTCC 选择 T1。 | — | `tools/macros.cfg` |
| `T2` | — | 通过 KTCC 选择 T2。 | — | `tools/macros.cfg` |
| `T3` | — | T3 已启用时通过 KTCC 选择；当前未连接时给出明确错误。 | — | `tools/macros.cfg` |
| `DROP_TOOL` | — | 通过 KTCC 卸下当前工具。 | — | `tools/macros.cfg` |
| `TX` | — | `DROP_TOOL` 的简短别名，用于卸下当前工具。 | — | `tools/macros.cfg` |
| `UNLOCK_TOOL` | — | 直接请求 KTCC 解锁工具。 | — | `tools/macros.cfg` |
| `CHECK_TOOL` | — | 查询工具检测开关并检查期望的 `mounted`/`unmounted` 状态。 | — | `tools/check.cfg` |
| `_CHECK_MOUNT_STATE` | — | 根据最近一次 endstop 查询结果执行底层安装状态断言。 | — | `tools/check.cfg` |
| `COUPLER_RESET` | — | 降低电流寻找耦合器机械基准，恢复电流后回到锁定位置。 | — | `tools/coupler.cfg` |
| `COUPLER_LOCK` | — | 必要时先复位，然后将耦合器移动到锁定位置。 | KTCC（`tool_lock_gcode`） | `tools/coupler.cfg` |
| `COUPLER_UNLOCK` | — | 必要时先复位，然后将耦合器移动到解锁位置。 | KTCC（`tool_unlock_gcode`） | `tools/coupler.cfg` |
| `SET_TOOL_RETRACTION` | — | 为指定工具设置并交给 KTCC 管理回抽参数。 | — | `tools/macros.cfg` |
| `SET_TOOL_PRESSURE_ADVANCE` | — | 为指定工具设置 pressure advance，并要求 KTCC 保存该工具参数。 | — | `tools/macros.cfg` |
| `MANUAL_Z_ALIGN` | — | 拾取指定工具并进入手动 Z offset 调整流程。 | — | `tools/alignment.cfg` |
| `MANUAL_Z_ALIGN_SAVE` | — | 记录手动 Z 对齐的初始位置。 | — | `tools/alignment.cfg` |
| `MANUAL_Z_ALIGN_CALC` | — | 根据当前位置与初始位置计算并保存新的工具 Z offset。 | — | `tools/alignment.cfg` |
| `MANUAL_Z_ALIGN_CANCEL` | — | 取消手动 Z 对齐、清除临时状态并按需卸下工具。 | — | `tools/alignment.cfg` |
| `ALIGN_TOOLS` | — | 调用 KTCC，在探针点自动测量并对齐所选工具。 | — | `tools/alignment.cfg` |
| `SET_ALL_TOOL_TEMPERATURE` | — | 将所有当前已启用工具设置为指定的对齐准备温度。 | — | `tools/alignment.cfg` |

## 覆盖命令与兼容命令

| 命令 | 原始命令 | 功能 | 外部调用者 | 定义文件 |
| --- | --- | --- | --- | --- |
| `G28` | `G28.0` | 增加热床温度、工具状态、CoreXY 安全位置、电机电流和 Z 避让检查后调用原始归零。 | KTCC（内部归零及包装器） | `macros/G28.cfg` |
| `_CG28` | — | 仅在 XYZ 尚未全部归零时调用安全版 `G28`。 | — | `macros/G28.cfg` |
| `BED_MESH_CALIBRATE` | `_BED_MESH_CALIBRATE` | 确认未安装工具且 XYZ 已归零，然后按配置调用 Klipper 原生 adaptive/full mesh，并透传调用参数。 | — | `macros/G29.cfg` |
| `G29` | — | 清除当前 mesh 后调用安全版 `BED_MESH_CALIBRATE`。 | — | `macros/G29.cfg` |
| `TURN_OFF_HEATERS` | `_TURN_OFF_HEATERS` | 先关闭所有 KTCC 工具加热器，再调用 Klipper 原始全加热器关闭命令。 | — | `macros/heaters.cfg` |
| `M84` | `M84.0` | 如有已安装工具则先卸下，再调用原始电机释放命令。 | — | `macros/M18.cfg` |
| `M18` | `M18.0` | 与 `M84` 相同：先安全卸下工具，再释放电机。 | — | `macros/M18.cfg` |
| `SET_RETRACTION` | `SET_RETRACTION_ORIG` | 将 Klipper firmware retraction 参数重定向到当前 KTCC 工具。 | — | `tools/macros.cfg` |
| `SET_PRESSURE_ADVANCE` | `SET_PRESSURE_ADVANCE_ORIG` | 将 Klipper pressure advance 参数重定向到 KTCC 工具管理。 | — | `macros/pressure_adv.cfg` |
| `M104` | `M104.0` | 将 `T`/`S` 参数转换为 KTCC 活动、待机工具温度设置，不等待升温。 | — | `tools/M104.cfg` |
| `M109` | `M109.0` | 设置指定/当前工具温度，并等待进入 2°C 容差。 | — | `tools/M109.cfg` |
| `CANCEL_PRINT` | `_CANCEL_PRINT` | 调用被重命名的既有取消流程后卸下工具，并关闭加热器、风扇和电机；既有命令通常由 Mainsail 提供。 | Mainsail（取消打印及 `on_error_gcode`） | `macros/cancel.cfg` |
| `M106` | — | 使用 `P` 选择工具并设置其 part fan；`S` 接受 0–1 或 2–255。 | — | `tools/M106.cfg` |
| `M107` | — | 通过 `M106 ... S0` 关闭指定或当前工具的 part fan。 | — | `tools/M107.cfg` |
| `M116` | — | 提供 RepRapFirmware 风格的工具/加热器温度等待命令。 | — | `tools/M116.cfg` |
| `M568` | — | 提供 RepRapFirmware 风格的工具活动温度、待机温度和加热状态设置。 | — | `tools/M568.cfg` |

## 打印、温度、耗材与风扇

| 命令 | 原始命令 | 功能 | 外部调用者 | 定义文件 |
| --- | --- | --- | --- | --- |
| `PRINT_BEGIN` | — | 校验切片器参数，处理工具与热床温度、归零、adaptive mesh、heat soak、初始工具和 purge。 | — | `macros/startstop.cfg` |
| `PRINT_END` | — | 卸下工具、关闭加热和 mesh、降低平台、释放电机、记录统计并延迟关闭风扇。 | — | `macros/startstop.cfg` |
| `EXTRUDER_OFF` | — | 禁用所有当前存在的挤出机步进电机。 | — | `macros/startstop.cfg` |
| `LOAD_FILAMENT` | — | 选择并加热工具，按每工具路径参数装料、purge，并可设置 PA/回抽。 | — | `macros/filament.cfg` |
| `UNLOAD_FILAMENT` | — | 选择并加热工具，软化耗材头后按每工具路径参数退料。 | — | `macros/filament.cfg` |
| `COLD_PULL` | — | 按指定工具执行加热、降温、摆动和拉出流程，并临时管理最低挤出温度。 | — | `macros/coldpull.cfg` |
| `PRIME_TOOL` | — | 在指定起点生成固定位置的多道 nozzle prime 线。 | — | `macros/prime.cfg` |
| `ADAPTIVE_PURGE` | — | 根据 `[exclude_object]` 边界选择模型附近的空间，先挤出 blob 再生成多道 purge 线。 | — | `macros/prime.cfg` |
| `DRY_FILAMENT` | — | 归零并把平台移动到干燥高度，使用 AC 热床执行带超时和状态跟踪的耗材干燥周期。 | — | `macros/filament_dryer.cfg` |
| `CANCEL_FILAMENT_DRYER` | — | 取消活动中的热床干燥周期并关闭热床。 | — | `macros/filament_dryer.cfg` |
| `_STOP_FILAMENT_DRYER` | — | 停止 dryer 回调、按原因更新内部状态，并按需关闭热床。 | — | `macros/filament_dryer.cfg` |
| `HEAT_SOAK` | — | 将热床加热到目标温度并按设定时长执行非阻塞 heat-soak 周期。 | — | `macros/heatsoak.cfg` |
| `CANCEL_HEAT_SOAK` | — | 取消正在进行的 heat-soak 周期并清理其状态。 | — | `macros/heatsoak.cfg` |
| `SET_TOOLS_FAN` | — | 将相同速度应用到所有当前启用工具的 part fan。 | — | `macros/fans.cfg` |
| `FAN_OFF` | — | 关闭所有当前启用工具的 part fan。 | — | `macros/fans.cfg` |
| `LED_ON` | — | 打开机箱 LED。 | — | `macros/led.cfg` |
| `LED_OFF` | — | 关闭机箱 LED。 | — | `macros/led.cfg` |

## 网床、运动与维护辅助

| 命令 | 原始命令 | 功能 | 外部调用者 | 定义文件 |
| --- | --- | --- | --- | --- |
| `MANUAL_BED_CALIBRATE` | — | 确保无工具、执行必要归零，并在完整配置范围生成固定 3×3 手动维护 mesh。 | — | `macros/G29.cfg` |
| `_MANUAL_BED_PROBE_POINT` | — | 移动到 FL/FR/BR/BL 固定点之一，执行单点 `PROBE` 并抬起平台。 | — | `macros/G29.cfg` |
| `REMEMBER_POSITION` | — | 动态开启或关闭换刀后的打印位置恢复功能。 | — | `macros/settings.cfg` |
| `PARK_CENTER` | — | 必要时归零，然后移动到热床中心。 | — | `macros/utility.cfg` |
| `PARK_FRONT` | — | 必要时归零并抬高安全 Z，然后按工具安装状态移动到机身前方。 | — | `macros/utility.cfg` |
| `ALIGN_DOCKING` | — | 对指定工具执行停靠位置的锁定/退出/再次进入/解锁检查动作。 | — | `macros/utility.cfg` |

## 调试与测量

| 命令 | 原始命令 | 功能 | 外部调用者 | 定义文件 |
| --- | --- | --- | --- | --- |
| `DUMP_PARAMETER` | — | 输出指定 printer 状态、配置或 settings 数据，供宏调试使用。 | — | `macros/debug.cfg` |
| `DUMP_PRINT_AREA_LIMITS` | — | 输出打印体积以及结合 probe offset 后的可探测范围。 | — | `macros/debug.cfg` |
| `GENERATE_SHAPER_GRAPHS` | — | 调用外部脚本采集 X/Y resonance 数据并生成 input-shaper 图表。 | — | `macros/graphs.cfg` |
| `MEASURE_COREXY_BELT_TENSION` | — | 采集 CoreXY 两条皮带的 resonance 数据并生成张力对比图。 | — | `macros/graphs.cfg` |
