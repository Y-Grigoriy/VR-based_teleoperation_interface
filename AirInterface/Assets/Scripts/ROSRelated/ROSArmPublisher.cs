using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RosSharp.RosBridgeClient;

namespace RosSharp.RosBridgeClient
{
    public class ROSArmPublisher : UnityPublisher<MessageTypes.Std.String>
    {
        private Queue<string> msgQueue = new Queue<string>();
        private MessageTypes.Std.String message;

        protected override void Start()
        {
            base.Start();
            InitializeMessage();
        }

        private void InitializeMessage()
        {
            message = new MessageTypes.Std.String
            {
                data = ""
            };
        }
        
        public void send(string payload)
        {
            if(payload.Length > 0)
                msgQueue.Enqueue(payload);
        }

        public int queueLength()
        {
            return msgQueue.Count;
        }

        void FixedUpdate()
        {
            if(msgQueue.Count > 0)
            {
                message.data = msgQueue.Dequeue();
                Publish(message);
            }
        }
    }
}
