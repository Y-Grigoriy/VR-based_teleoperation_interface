using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WebCams : MonoBehaviour
{
    static WebCamTexture webCamTexture;
    private string[] nameWebCams;

    //The current webcam  
    private int currentCam = 0;

    //The selected webcam  
    private int selectedCam = 0;
    // Start is called before the first frame update
    void Start()
    {
        int numOfCams = WebCamTexture.devices.Length;

        //Initialize the nameWebCams array to hold the same number of strings as there are webcams  
        this.nameWebCams = new string[numOfCams];

        //Get the name of each connected camera and store it into the 'nameWebCams' array  
        for (int i = 0; i < numOfCams; i++)
        {
            this.nameWebCams[i] = WebCamTexture.devices[i].name;
        }

        //Initialize the webCamTexture  
        webCamTexture = new WebCamTexture();
        Renderer renderer = GetComponent<Renderer>();
        //Assign the images captured by the first available webcam as the texture of the containing game object  
        renderer.material.mainTexture = webCamTexture;
        //Start streaming the images captured by the webcam into the texture  
        webCamTexture.deviceName = WebCamTexture.devices[1].name;
        webCamTexture.Play();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            webCamTexture.Stop();
            //Assign a different webcam to the webCamTexture  
            webCamTexture.deviceName = WebCamTexture.devices[0].name;
            //Start streaming the captured images from this webcam to the texture  
            webCamTexture.Play();
        }

        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            webCamTexture.Stop();
            //Assign a different webcam to the webCamTexture  
            webCamTexture.deviceName = WebCamTexture.devices[1].name;
            //Start streaming the captured images from this webcam to the texture  
            webCamTexture.Play();
        }

        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            webCamTexture.Stop();
            //Assign a different webcam to the webCamTexture  
            webCamTexture.deviceName = WebCamTexture.devices[2].name;
            //Start streaming the captured images from this webcam to the texture  
            webCamTexture.Play();
        }
    }
}
