/// Generated by robomake

#pragma once

#include <SampleRobot.h>

#include "subsystems/NumberSubsystem.hpp"


class Robot : public frc::SampleRobot {
public:
	Robot();

	void RobotInit() override;
private:
	NumberManager* numberManager;
};