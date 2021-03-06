#pragma once

#include "cqhttp/core/plugin.h"

namespace cqhttp::plugins {
    struct EventDataPatcher : Plugin {
        void hook_after_event(EventContext<cq::Event> &ctx) override;
    };

    static std::shared_ptr<EventDataPatcher> event_data_patcher = std::make_shared<EventDataPatcher>();
} // namespace cqhttp::plugins
