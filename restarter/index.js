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
    const client = new InstancesClient();

    // Get current instance info
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
      // Start the VM if it's stopped
      await client.start({
        project: projectId,
        zone: zoneName,
        instance: instanceName,
      });

      res.status(200).send(`VM ${instanceName} was stopped. Restarting now. Current External IP: ${externalIP}`);
    } else {
      // VM is already running
      res.status(200).send(`VM ${instanceName} is already running. External IP: ${externalIP}`);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to check or restart VM: ' + err.message);
  }
});

exports.restartMinecraftVM = app;
