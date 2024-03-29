/* 
 * This message is auto generated by ROS#. Please DO NOT modify.
 * Note:
 * - Comments from the original code will be written in their own line 
 * - Variable sized arrays will be initialized to array of size 0 
 * Please report any issues at 
 * <https://github.com/siemens/ros-sharp> 
 */



namespace RosSharp.RosBridgeClient.MessageTypes.Px4Control
{
    public class UnityGetStateResponse : Message
    {
        public const string RosMessageName = "px4_control/UnityGetState";

        //  Request constants
        public const sbyte ONGROUND = 1;
        public const sbyte INAIR = 2;
        //  Request fields
        public sbyte get_state { get; set; }

        public UnityGetStateResponse()
        {
            this.get_state = 0;
        }

        public UnityGetStateResponse(sbyte get_state)
        {
            this.get_state = get_state;
        }
    }
}
