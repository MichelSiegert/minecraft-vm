require('dotenv').config();
const express = require('express');
const { InstancesClient } = require('@google-cloud/compute');

const app = express();
app.use(express.json());

const zoneName = process.env.ZONE_NAME;
const instanceName = process.env.INSTANCE_NAME;
const projectId = process.env.GCP_PROJECT_ID;

app.get('/', async (req, res) => {
  try {

    if((req.query.user ?? "") == ""){
      res.setMaxListeners(400).send("request misses params!");
      return;
    }
    
    const client = new InstancesClient();

    const [instance] = await client.get({
      project: projectId,
      zone: zoneName,
      instance: instanceName,
    });

    const status = instance.status;
    const networkInterface = instance.networkInterfaces?.[0];
    const accessConfig = networkInterface?.accessConfigs?.[0];
    const externalIP = accessConfig?.natIP || 'No external IP assigned';

    if (status === 'TERMINATED') {
      await client.start({
        project: projectId,
        zone: zoneName,
        instance: instanceName,
      });

      res.status(200).send(`VM ${instanceName} was stopped. Restarting now. Current External IP: ${externalIP}`);
    } else {
      res.status(200).send(`VM ${instanceName} is already running. External IP: ${externalIP}`);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to check or restart VM: ' + err.message);
  }
});

exports.restartMinecraftVM = app;
