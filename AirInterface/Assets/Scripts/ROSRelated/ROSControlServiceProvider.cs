using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using RosSharp.RosBridgeClient;
using RosSharp.RosBridgeClient.MessageTypes.Px4Control;

public class ROSControlServiceProvider : MonoBehaviour
{
    private sbyte state = UnityGetStateResponse.ONGROUND; // 1 = OnGround, 2 = InAir
    private sbyte mode = UnitySetStateRequest.LAND; // 0 = land, 1 = takeoff, 2 = hover, 3 = posctl
    private sbyte updatedMode = UnitySetStateRequest.LAND;
    private bool requestLock = false;
    private static Dictionary<sbyte, string> robotModes = new Dictionary<sbyte, string>()
    {
        { UnitySetStateRequest.LAND, "LAND" },
        { UnitySetStateRequest.TAKEOFF,"TAKEOFF" },
        { UnitySetStateRequest.HOVER, "HOVER" },
        { UnitySetStateRequest.POSCTL, "POSCTL" }
    };


    public sbyte State { get { return state; } }
    public sbyte Mode { get { return mode; } }
    public RosConnector rosConnector;

    void Start()
    {
        InvokeRepeating("getState", 2.0f, 0.1f);
    }

    private void getState()
    {
        UnityGetStateRequest request = new UnityGetStateRequest();
        rosConnector.RosSocket.CallService<UnityGetStateRequest, UnityGetStateResponse>("/unity/get_state", getStateHandler, request);
    }

    public void setMode(sbyte set_mode)
    {
        if(!this.requestLock)
        {
            this.requestLock = true;
            this.updatedMode = set_mode;
            if(mode == UnitySetStateRequest.TAKEOFF && state == UnityGetStateResponse.INAIR)
            {
                set_mode = UnitySetStateRequest.HOVER;
            }
            UnitySetStateRequest request = new UnitySetStateRequest(set_mode);
            rosConnector.RosSocket.CallService<UnitySetStateRequest, UnitySetStateResponse>("/unity/set_state", setStateHandler, request);
        }
    }

    public string getModeName()
    {
        return robotModes[mode];
    }

    private void getStateHandler(UnityGetStateResponse resp)
    {
        this.state = resp.get_state;
    }

    private void setStateHandler(UnitySetStateResponse resp)
    {
        if(resp.status)
        {
            this.mode = this.updatedMode;
            this.requestLock = false;
        }
    }
}
