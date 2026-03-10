use crate::tabs::TabName;
use egui_dock::{DockState, NodeIndex};
use strum_macros::{Display, EnumIter};

#[derive(Debug, Clone, serde::Deserialize, serde::Serialize, EnumIter, Display)]
pub enum LayoutPresetName {
    // TODO: consider providing the list of locked tabs to these functions, and make them
    //   render a custom default depending on which tabs are available. Passing in only the widget
    //   boolean is odd.
    //   The trouble with not having everything unlocked by default is that I don't have a good way
    //   to open new tabs in reasonable locations. It's a downside of immediate mode.
    //   If I continue with the approach of allowing tabs to be locked, I need to have a way
    //   to add new tabs as they are unlocked, even if it adds them to a weird spot.
    ThreePanelsWithLogsBottomCenter,
    SinglePanel,
    TwoTabs,
    TwoPanels,
}

impl LayoutPresetName {
    #[must_use]
    pub fn dock_state(&self) -> DockState<TabName> {
        match self {
            LayoutPresetName::SinglePanel => only_center(),
            LayoutPresetName::TwoTabs => two_tabs(),
            LayoutPresetName::TwoPanels => two_panels(),
            LayoutPresetName::ThreePanelsWithLogsBottomCenter => three_panels(),
        }
    }
}

fn only_center() -> DockState<TabName> {
    DockState::new(vec![TabName::CenterPanel])
}

fn two_tabs() -> DockState<TabName> {
    use TabName::{LeftPanel, RightPanel};
    DockState::new(vec![LeftPanel, RightPanel])
}

fn two_panels() -> DockState<TabName> {
    use TabName::{LeftPanel, RightPanel};

    let mut state = DockState::new(vec![RightPanel]);

    // Split to the left.
    let [_, _] = state.main_surface_mut().split_left(NodeIndex::root(), 0.4, vec![LeftPanel]);

    state
}

fn three_panels() -> DockState<TabName> {
    use TabName::{LeftPanel, RightPanel, Logs, CenterPanel};

    let mut state = DockState::new(vec![CenterPanel]);

    // Logs goes below it.
    let [_, _] = state
        .main_surface_mut()
        .split_below(NodeIndex::root(), 0.3, vec![Logs]);

    // Split everything left.
    let [_, _] = state.main_surface_mut().split_left(NodeIndex::root(), 0.4, vec![LeftPanel]);

    // Split everything right.
    let [_, _] = state.main_surface_mut().split_right(NodeIndex::root(), 0.8, vec![RightPanel]);

    state
}

// fn initial_attempt() -> DockState<TabName> {
//     use TabName::{LeftPanel, CenterPanel};
//
//     // Start with Widgets in the main area
//     let mut state = DockState::new(vec![Location, Artifacts]);
//
//     // Split left: Widgets stays on right, Locations goes to new left area
//     let [_widgets_area, mut current_left] = state.main_surface_mut().split_left(NodeIndex::root(), 0.2, vec![Map]);
//
//     // Add remaining left sidebar tabs with equal spacing
//     let left_tabs = vec![Stats, Skills, Equipment, LeftPanel];
//     for (i, tab) in left_tabs.into_iter().enumerate() {
//         // For equal distribution, calculate the ratio of remaining space.
//         // It is extremely important to not ever have a ratio of 1.0
//         // as that causes a known bug in egui_dock: https://github.com/Adanos020/egui_dock/issues/282
//         let ratio = 1.0 / (4 - i + 1) as f32; // 1/5, 1/4, 1/3, 1/2
//         let [_prev_area, new_area] = state.main_surface_mut().split_below(current_left, ratio, vec![tab]);
//         current_left = new_area;
//     }
//
//     // Split the right side to add Logs below Widgets
//     let [_widgets_area, _logs_area] = state.main_surface_mut().split_below(NodeIndex::root(), 0.7, vec![CenterPanel]);
//
//     state
// }
