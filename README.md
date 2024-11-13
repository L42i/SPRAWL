# SPRAWL (3.0)

The latest incarnation of the network-meta-instrument SPRAWL, after:

- [SPRAWL 1.0](https://github.com/anwaldt/SPRAWL): 2019-2020, with Chris Chafe and Nils Tonnaett
- [SPRAWL 2.0](https://github.com/ringbuffer-org/SPRAWL): 2022-2023 with Max Weidauer 

# Hardware

The hardware of 16 Access Points has been upgraded to:

- Raspberry PI 5
- Fucusrite Scarlett 4i4
- 10' touchscreen
- Neumann KH120

# Running Playbooks


## Without SSH Keys

Install ssh pass:

    apt isntall sshpass

With no ssh keys deployed, the playbooks can be executed with the following command:

    ansible-playbook -k -i ../../../config/hosts.ini  mesh_servers.yml

The '-k' argument will initiate a query for the user password on the PI.
