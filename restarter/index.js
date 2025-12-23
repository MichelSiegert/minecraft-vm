require('dotenv').config();
const express = require('express');
const { InstancesClient } = require('@google-cloud/compute');

const app = express();
app.use(express.json());

const zoneName = process.env.ZONE_NAME;
const instanceName = process.env.INSTANCE_NAME;
const projectId = process.env.GCP_PROJECT_ID;

async function waitForExternalIP(client, projectId, zoneName, instanceName) {
  for (let i = 0; i < 30; i++) {
    const [inst] = await client.get({
      project: projectId,
      zone: zoneName,
      instance: instanceName,
    });

    const nic = inst.networkInterfaces?.[0];
    const ip = nic?.accessConfigs?.[0]?.natIP;

    if (ip) return ip;

    await new Promise(r => setTimeout(r, 1000));
  }

  return 'No external IP assigned';
}

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

    if (status === 'TERMINATED') {
      await client.start({
        project: projectId,
        zone: zoneName,
        instance: instanceName,
      });
      const externalIP = await waitForExternalIP(client, projectId, zoneName, instanceName);

      res.status(200).send(externalIP);
    } else {
      const externalIP = await waitForExternalIP(client, projectId, zoneName, instanceName);
      res.status(200).send(externalIP);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to check or restart VM: ' + err.message);
  }
});

exports.restartMinecraftVM = app;
