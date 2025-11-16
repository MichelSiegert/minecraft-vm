require('dotenv').config();
const express = require('express');
const {InstancesClient} = require('@google-cloud/compute'); 

const app = express();
app.use(express.json());

const zoneName = process.env.ZONE_NAME;
const instanceName = process.env.INSTANCE_NAME;
const projectId = process.env.GCP_PROJECT_ID;

app.get('/', async (req, res) => {
  try {
    const client = new InstancesClient();

    await client.start({
      project: projectId,
      zone: zoneName,
      instance: instanceName,
    });

    res.status(200).send(`VM ${instanceName} is restarting.`);
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to restart VM: ' + err.message);
  }
});

exports.restartMinecraftVM = app;
