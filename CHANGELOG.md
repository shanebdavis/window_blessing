### vXXX

Improvement

 * Track more than one redraw area. Two small redraw areas no longer become one large one.

Added

 * EventedVariable#before_filter
 * :fg and :bg options to Buffer#normalize
 * EventManager#on_event_exception
 * EventManager#on_every_event
 * EventManager#on_unhandled_event
 * simplified keyboard event modifier encoding (shift/alt/control)
 * fixed keyboard modifiers for pageup/down/home/end & f5-f10

Removed  

 * redraw time log
 
Changed Events

 * Escape: [:key_press, :escape]
 * Enter: [:key_press, :enter]
 * Tab: [:key_press, :tab]
 * Control-Letter: [:kre_press, :[letter]]

### v0.0.2, 2013-02-17

  BugFixes
