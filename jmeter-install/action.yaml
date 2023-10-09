name : 'Install Jmeter'
Description : 'Installing Jmeter'
runs : 
  using : "composite"
  steps : 
    - name: Install_JMeter
      run: |
        echo "I'm here in yaml"
        chmod 700 ${{ github.action_path }}/Jmeterinstall.sh
        sh ${{ github.action_path }}/JmeterInstall.sh
        shell: bash
