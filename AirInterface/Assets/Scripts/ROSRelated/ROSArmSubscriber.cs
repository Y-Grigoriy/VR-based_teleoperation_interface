using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RosSharp.RosBridgeClient;

namespace RosSharp.RosBridgeClient
{
    public class ROSArmSubscriber : UnitySubscriber<MessageTypes.Std.String>
    {
        private Queue<string> msgQueue = new Queue<string>();

        protected override void Start()
        {
            base.Start();
        }

        protected override void ReceiveMessage(MessageTypes.Std.String message)
        {
            msgQueue.Enqueue(message.data);
        }

        public string receive()
        {
            if (msgQueue.Count == 0) return "";
            return msgQueue.Dequeue();
        }

        public int queueLength()
        {
            return msgQueue.Count;
        }
    }
}
