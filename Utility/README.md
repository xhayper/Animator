# Animator/Utility
Contains useful script that will help you

## Tools
* KeyframeSequence-To-AnimationData - Turn KeyframeSequence into AnimationData
* AccessoryWeld-To-Motor6D - Turn AccessoryWeld into Motor6D

## Data Structure

```lua

-- Pose Data

{
	Name: string,
	CFrame: CFrame,
	EasingDirection: Enum.EasingDirection,
	EasingStyle: Enum.EasingStyle,
	Weight: number,
	Subpose?: {} -- Array of Pose Data
}

-- Marker Data

"Marker Name" = {
	Value: any
}

-- Frame Data

{
	Name:string,
	Time:number,
	Pose: {}, -- Array of Pose data
	Marker?: {} -- Array of Marker Data
}

-- Animation Data

{
	Loop:bool,
	Priority:Enum.AnimationPriority,
	Frames: {} -- Array of Frame Data
}

-- Example


-- Modified Roblox R6 Idle
{
    Loop = true,
    Frames = {
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, -1.78813934e-07, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, -1.78813934e-07, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-6.55185431e-07, -0.00310271978, -2.38418579e-07, 0.999970019, 0.000907999871, -0.0076489998, -0.000906999863, 0.999999762, 0.000198999973, 0.00765000004, -0.000191999978, 0.999970973),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-3.29775503e-07, 2.56001949e-05, -5.96046448e-07, 1, 0.000557999883, -0.000220000002, -0.000557999883, 0.999998748, 0.00100899977, 0.000220999995, -0.00100899977, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.08169997e-08, 0, 0, 1, -0.000257000007, 0, 0.000257000007, 1, 0.000161999997, 0, -0.000161999997, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.00182999996, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00169575214, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0013667345, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.31331796e-07, 0.00769022107, 0, 0.999998987, -0.00127399981, -0.000957000011, 0.00127499981, 0.999998748, 0.00110299978, 0.000956000003, -0.00110399979, 0.999998987),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(3.67872417e-07, 0.00413259864, -5.96046448e-08, 0.999984026, 0.00389499962, -0.00420500012, -0.00387799949, 0.999984741, 0.00389099959, 0.00422, -0.00387399946, 0.999984026),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.03089491e-07, 1.16415322e-10, -3.27825546e-07, 1, 0.000308999995, 0, -0.000308999995, 0.99999702, 0.002569, 9.99999997e-07, -0.002569, 0.99999702),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.050000000745058
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.00392800011, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00363874435, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00293374062, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(6.0768798e-08, 0.01106444, 0, 0.99999702, -0.00223199953, 0.00132100005, 0.00222899951, 0.999994755, 0.00206799945, -0.00132599997, -0.00206499943, 0.99999702),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-4.12575901e-07, 0.00589865446, -2.98023224e-07, 0.999967992, 0.00473999884, -0.00641799998, -0.00470399903, 0.999971747, 0.00575599913, 0.00644499995, -0.0057259989, 0.999962986),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(2.23423967e-07, 6.98491931e-10, -1.49011612e-07, 1, 0.000647999987, 0, -0.000647999987, 0.999993026, 0.00377600011, 1.99999999e-06, -0.00377600011, 0.999993026),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.10000000149012
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.00981099997, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00908774137, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00732678175, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.42725185e-07, 0.0151169896, 3.57627869e-07, 0.99998498, -0.00369899953, 0.00408300012, 0.00368099962, 0.999983788, 0.00430999929, -0.00409899978, -0.00429499894, 0.999981999),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.69152224e-07, 0.00829565525, -6.55651093e-07, 0.999936998, 0.00549599901, -0.00974899996, -0.00540899904, 0.999944746, 0.00894699804, 0.00979799964, -0.00889399834, 0.999912977),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.39858003e-07, 2.32830644e-09, -5.66244125e-07, 0.999998987, 0.00130300003, 0, -0.00130300003, 0.999981999, 0.00592500018, 7.99999998e-06, -0.00592500018, 0.999983013),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.15000000596046
        },
        {
            Marker = {
                ThisIs = {
                    {
                        Value = "AnExample"
                    }
                }
            },
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.013305, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0123237371, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00993573666, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.00234354e-07, 0.0158981383, -3.57627869e-07, 0.999980986, -0.00412699906, 0.00459899986, 0.00410299888, 0.999977767, 0.00525599904, -0.00461999979, -0.00523699913, 0.999975979),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.05239451e-07, 0.00862297416, 3.57627869e-07, 0.999934018, 0.005371999, -0.0101490002, -0.00527299894, 0.999938786, 0.00975599792, 0.0102009997, -0.00970099773, 0.999900997),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.29795205e-07, 5.12227416e-09, 1.49011612e-07, 0.999998987, 0.001559, 0, -0.001559, 0.999975979, 0.00676100003, 1.10000001e-05, -0.00676100003, 0.999976993),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.20000000298023
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0206470005, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0191247463, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0154187679, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(4.51691449e-08, 0.0146181285, 5.96046448e-08, 0.99998498, -0.0041019991, 0.00376200001, 0.00407899916, 0.999973774, 0.00602699909, -0.00378699997, -0.00601099897, 0.999975026),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(2.27708369e-07, 0.00702494383, -2.98023224e-07, 0.999961019, 0.00371299963, -0.00797300041, -0.00363799953, 0.99994874, 0.00941199809, 0.0080070002, -0.00938299857, 0.999924004),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.4819625e-07, 8.61473382e-09, 4.17232513e-07, 0.999997973, 0.00178199995, 0, -0.00178199995, 0.999969006, 0.00768999988, 1.40000002e-05, -0.00768999988, 0.999970019),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.25
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0274420008, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0254197717, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0204937458, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.04425305e-07, 0.00869509578, -2.38418579e-07, 0.999996006, -0.00281899958, 1.40000002e-05, 0.00281899958, 0.999978781, 0.00586799905, -2.99999992e-05, -0.00586799905, 0.999983013),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-5.36791049e-07, 0.00346282125, -1.78813934e-07, 0.99999398, 0.000580999884, -0.00329599995, -0.000555999868, 0.99996978, 0.00771999918, 0.00330099999, -0.00771799916, 0.999965012),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(2.43891463e-07, 3.49245965e-09, -3.87430191e-07, 0.999998987, 0.00144400005, 0, -0.00144400005, 0.999972999, 0.00726300012, 9.99999975e-06, -0.00726300012, 0.999974012),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.30000001192093
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0302590001, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0280287862, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0225967765, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(4.12197551e-07, 0.00434982777, 1.1920929e-07, 0.999994993, -0.00184999977, -0.00274299993, 0.00186599977, 0.999981761, 0.00569399912, 0.00273200008, -0.00569899892, 0.999979973),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.55327905e-07, 0.00131368637, -5.96046448e-08, 0.999998987, -0.0012429998, -0.000502999988, 0.00124599983, 0.999976754, 0.00660099927, 0.000494999986, -0.00660199905, 0.999978006),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-6.40611688e-08, 4.65661287e-10, -3.27825546e-07, 1, 0.00105299999, 0, -0.00105299999, 0.999978006, 0.00652599987, 7.0000001e-06, -0.00652599987, 0.999979019),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.34999999403954
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0340140015, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0315077305, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0254007578, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-3.49711627e-07, -0.00587049127, -1.1920929e-07, 0.999957025, 0.000458999944, -0.00923100021, -0.000410999928, 0.999985754, 0.00519699929, 0.009234, -0.00519299926, 0.999943972),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-3.44123691e-07, -0.00306761265, -5.96046448e-08, 0.999975026, -0.00486399885, 0.00515699992, 0.00484199915, 0.999979734, 0.00418499904, -0.00517700007, -0.00415999908, 0.999978006),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-7.31849994e-08, 0, -2.68220901e-07, 1, -3.40000006e-05, 0, 3.40000006e-05, 0.999991, 0.00430499995, 0, -0.00430499995, 0.999991),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.40000000596046
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0346850008, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0321287513, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0259017348, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.61584467e-07, -0.0112549067, 1.1920929e-07, 0.999918997, 0.00168499979, -0.0126520004, -0.00162299979, 0.999986768, 0.00488799904, 0.0126599995, -0.00486699911, 0.99990797),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.03376806e-07, -0.0050381422, 5.96046448e-08, 0.999949992, -0.00644599926, 0.00768300006, 0.00642299885, 0.999974787, 0.00303699961, -0.00770199997, -0.00298699946, 0.999966025),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.25560291e-08, -8.14907253e-10, -3.57627869e-07, 1, -0.000668999972, 0, 0.000668999972, 0.999994993, 0.00295199989, -1.99999999e-06, -0.00295199989, 0.999996006),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.44999998807907
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0334220007, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0309587717, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0249587297, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(2.28174031e-07, -0.021243751, -2.38418579e-07, 0.999812007, 0.00397599908, -0.0190009996, -0.00389699964, 0.999983788, 0.00418599928, 0.0190169998, -0.00411099894, 0.999810994),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.12690032e-07, -0.007804811, -3.57627869e-07, 0.999900997, -0.00856799819, 0.0111910002, 0.00855499785, 0.999962747, 0.00127599982, -0.0112009998, -0.00117999979, 0.999936998),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.15699002e-07, -1.20053301e-10, 0, 0.999997973, -0.00196100003, 0, 0.00196100003, 0.999997973, 0.000118000004, 0, -0.000118000004, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.5
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0317340009, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0293957591, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0236987472, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(8.84756446e-08, -0.0253691971, 0, 0.999754012, 0.00493099913, -0.0216249991, -0.00484999921, 0.999980748, 0.00380499964, 0.0216429997, -0.00369899953, 0.999759018),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(5.51342964e-07, -0.00841578841, -3.57627869e-07, 0.999889016, -0.00896299817, 0.0119249998, 0.00895499811, 0.999959767, 0.000764999888, -0.0119319996, -0.000657999888, 0.999929011),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(8.20842843e-08, -2.03726813e-09, 2.38418579e-07, 0.99999702, -0.00255999994, 0, 0.00255999994, 0.999996006, -0.00123599998, 3.00000011e-06, 0.00123599998, 0.999998987),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.55000001192093
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0268070009, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0248307586, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0200187564, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.76019967e-07, -0.0306023955, 3.57627869e-07, 0.999669015, 0.00617099926, -0.0249579996, -0.00609799894, 0.999976754, 0.00301699946, 0.0249760002, -0.00286299945, 0.999683976),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.84984708e-07, -0.00852778554, 2.38418579e-07, 0.999891996, -0.00877599791, 0.0118180001, 0.00877399836, 0.999961734, 0.000187999976, -0.0118190004, -8.39999848e-05, 0.999930024),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.16197498e-07, -1.07102096e-08, -5.96046448e-08, 0.99999398, -0.00351099996, 0, 0.00351099996, 0.999988019, -0.00348399999, 1.20000004e-05, 0.00348399999, 0.99999398),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.60000002384186
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0237910002, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0220367312, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0177657604, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.89989805e-07, -0.0313878953, 4.17232513e-07, 0.999655008, 0.006380999, -0.0254660007, -0.0063159992, 0.999976754, 0.00262199948, 0.0254820008, -0.00245999964, 0.999671996),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-7.72997737e-08, -0.00827786326, 3.87430191e-07, 0.999900997, -0.00840399787, 0.0112859998, 0.00840499811, 0.999964774, -5.9999993e-06, -0.0112849995, 0.000100999983, 0.999935985),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(3.47245077e-08, -1.55996531e-08, 5.96046448e-08, 0.999993026, -0.00379800005, 0, 0.00379800005, 0.999984026, -0.00423099985, 1.6e-05, 0.00423099985, 0.999991),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.64999997615814
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.017213, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0159437656, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.0128547549, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-9.12696123e-08, -0.0298516154, -4.17232513e-07, 0.999677002, 0.00614999887, -0.0246769991, -0.006105999, 0.999979734, 0.00186399976, 0.0246879999, -0.00171299977, 0.99969399),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(2.21654773e-07, -0.0072774291, 4.17232513e-07, 0.999929011, -0.00721199904, 0.00947799999, 0.00721499929, 0.999973774, -0.000209999969, -0.00947600044, 0.000278999942, 0.999954998),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.43095201e-07, -1.95577741e-08, 3.87430191e-07, 0.999993026, -0.00384499994, 0, 0.00384499994, 0.999980986, -0.00481500011, 1.89999992e-05, 0.00481500011, 0.999988019),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.69999998807907
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.0106549999, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00986874104, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00795674324, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-8.38190317e-09, -0.024958998, -4.17232513e-07, 0.999741971, 0.00530299917, -0.0220989995, -0.00527799921, 0.999984741, 0.00118899974, 0.0221050009, -0.00107299979, 0.999755025),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(3.45520675e-07, -0.0057567358, 4.17232513e-07, 0.999960005, -0.00555399898, 0.00700700004, 0.005555999, 0.999984741, -0.000188999969, -0.0070059998, 0.000227999975, 0.999975026),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.05414835e-07, -1.28056854e-08, -2.68220901e-07, 0.999994993, -0.00321700005, 0, 0.00321700005, 0.99998498, -0.00453499984, 1.49999996e-05, 0.00453499984, 0.999989986),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.75
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.00766200013, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00709676743, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00572174788, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.35041773e-07, -0.0216066539, 2.98023224e-07, 0.999783993, 0.00470399903, -0.0202569999, -0.00468699913, 0.999988735, 0.000899999868, 0.0202610008, -0.000804999901, 0.999794006),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(4.414469e-07, -0.00485157967, 5.96046448e-08, 0.999974012, -0.00459299888, 0.00564699993, 0.00459399913, 0.999989748, -9.89999826e-05, -0.00564699993, 0.000124999977, 0.999984026),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.9166373e-07, -8.84756446e-09, 3.57627869e-07, 0.999996006, -0.0027389999, 0, 0.0027389999, 0.999988019, -0.00415599998, 1.10000001e-05, 0.00415599998, 0.999991),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.80000001192093
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.00280899997, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00260174274, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00209677219, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(3.66941094e-07, -0.013891995, 0, 0.999872983, 0.00324199954, -0.0156270005, -0.00323499949, 0.999994755, 0.000448999956, 0.0156280007, -0.000397999946, 0.999877989),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(4.81959432e-08, -0.00284588337, -3.57627869e-07, 0.999993026, -0.00248099957, 0.00291200005, 0.00248099957, 0.999996781, 0.00023499997, -0.00291200005, -0.000227999975, 0.999996006),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.06181915e-07, -1.0477379e-09, -3.27825546e-07, 0.999998987, -0.00162899995, 0, 0.00162899995, 0.99999398, -0.00293900003, 4.99999987e-06, 0.00293900003, 0.999996006),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.85000002384186
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, -0.00117199996, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.00108575821, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, 0.000874757767, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-3.7252903e-09, -0.00985515118, -1.78813934e-07, 0.99991399, 0.00241199951, -0.0128929997, -0.00240799948, 0.999996781, 0.000301999942, 0.0128939999, -0.000270999939, 0.999916971),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(6.51925802e-08, -0.00178596377, -5.36441803e-07, 0.999997973, -0.0013649998, 0.00163700001, 0.00136399979, 0.999998748, 0.000476999936, -0.00163800002, -0.00047499995, 0.999998987),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(1.11591021e-07, -1.16415322e-10, -1.1920929e-07, 0.999998987, -0.00107400003, 0, 0.00107400003, 0.99999702, -0.00206999993, 1.99999999e-06, 0.00206999993, 0.999997973),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.89999997615814
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "HumanoidRootPart",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Torso",
                            Weight = 1,
                            CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Subpose = {
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, -1.78813934e-07, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Leg",
                                    Weight = 1,
                                    CFrame = CFrame.new(0, -1.78813934e-07, 0, 1, 0, 0, 0, 0.999999762, 0, 0, 0, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Left Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-1.21071935e-07, -0.00243169069, -2.38418579e-07, 0.999975026, 0.000750999898, -0.00707799988, -0.00074999989, 0.999999762, 0.000198999973, 0.00707799988, -0.000193999964, 0.999975026),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Right Arm",
                                    Weight = 1,
                                    CFrame = CFrame.new(-2.64961272e-07, 0.000206887722, 2.38418579e-07, 1, 0.000751999905, -0.000311999989, -0.000751999905, 0.999998748, 0.00107099977, 0.000312999997, -0.00107099977, 0.999998987),
                                    EasingDirection = Enum.EasingDirection.In
                                },
                                {
                                    EasingStyle = Enum.EasingStyle.Linear,
                                    Name = "Head",
                                    Weight = 1,
                                    CFrame = CFrame.new(-5.13000025e-08, 0, -1.1920929e-07, 1, -0.000216, 0, 0.000216, 1, 0.000475000008, 0, -0.000475000008, 1),
                                    EasingDirection = Enum.EasingDirection.In
                                }
                            },
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "Keyframe",
            Time = 0.94999998807907
        },
        {
            Pose = {
                {
                    EasingStyle = Enum.EasingStyle.Linear,
                    Name = "Torso",
                    Weight = 1,
                    CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Subpose = {
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Left Arm",
                            Weight = 1,
                            CFrame = CFrame.new(-6.55185431e-07, -0.00310271978, -2.38418579e-07, 0.999970019, 0.000907999871, -0.0076489998, -0.000906999863, 0.999999762, 0.000198999973, 0.00765000004, -0.000191999978, 0.999970973),
                            EasingDirection = Enum.EasingDirection.In
                        },
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Right Arm",
                            Weight = 1,
                            CFrame = CFrame.new(-3.29775503e-07, 2.56001949e-05, -5.96046448e-07, 1, 0.000557999883, -0.000220000002, -0.000557999883, 0.999998748, 0.00100899977, 0.000220999995, -0.00100899977, 1),
                            EasingDirection = Enum.EasingDirection.In
                        },
                        {
                            EasingStyle = Enum.EasingStyle.Linear,
                            Name = "Head",
                            Weight = 1,
                            CFrame = CFrame.new(-2.08169997e-08, 0, 0, 1, -0.000257000007, 0, 0.000257000007, 1, 0.000161999997, 0, -0.000161999997, 1),
                            EasingDirection = Enum.EasingDirection.In
                        }
                    },
                    EasingDirection = Enum.EasingDirection.In
                }
            },
            Name = "End",
            Time = 1
        }
    },
    Priority = Enum.AnimationPriority.Core
}
```
