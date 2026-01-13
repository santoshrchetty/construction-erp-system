#!/usr/bin/env node

// Restore Point CLI Tool
const { RestorePointManager } = require('./lib/restorePoint')
const readline = require('readline')

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
})

const restoreManager = new RestorePointManager()

function showMenu() {
  console.log('\n🔄 Construction App - Restore Point Manager')
  console.log('==========================================')
  console.log('1. Create Restore Point')
  console.log('2. List Restore Points') 
  console.log('3. Restore from Point')
  console.log('4. Auto Backup Critical Files')
  console.log('5. Exit')
  console.log('==========================================')
}

function handleChoice(choice) {
  switch(choice) {
    case '1':
      rl.question('Enter description for restore point: ', (description) => {
        const id = restoreManager.autoBackup()
        console.log(`✅ Created restore point: ${id}`)
        showMenu()
        promptUser()
      })
      break
      
    case '2':
      const points = restoreManager.listRestorePoints()
      if (points.length === 0) {
        console.log('📭 No restore points found')
      } else {
        console.log('\n📋 Available Restore Points:')
        points.forEach((p, i) => {
          console.log(`${i + 1}. ${p.id} - ${p.description}`)
          console.log(`   Created: ${new Date(p.timestamp).toLocaleString()}`)
          console.log(`   Files: ${Object.keys(p.files).length}`)
        })
      }
      showMenu()
      promptUser()
      break
      
    case '3':
      const availablePoints = restoreManager.listRestorePoints()
      if (availablePoints.length === 0) {
        console.log('📭 No restore points available')
        showMenu()
        promptUser()
        return
      }
      
      console.log('\n📋 Select restore point:')
      availablePoints.forEach((p, i) => {
        console.log(`${i + 1}. ${p.description} (${new Date(p.timestamp).toLocaleString()})`)
      })
      
      rl.question('Enter number to restore: ', (num) => {
        const index = parseInt(num) - 1
        if (index >= 0 && index < availablePoints.length) {
          const success = restoreManager.restoreFromPoint(availablePoints[index].id)
          if (success) {
            console.log('✅ Restore completed successfully')
          } else {
            console.log('❌ Restore failed')
          }
        } else {
          console.log('❌ Invalid selection')
        }
        showMenu()
        promptUser()
      })
      break
      
    case '4':
      const autoId = restoreManager.autoBackup()
      console.log(`✅ Auto backup created: ${autoId}`)
      showMenu()
      promptUser()
      break
      
    case '5':
      console.log('👋 Goodbye!')
      rl.close()
      break
      
    default:
      console.log('❌ Invalid choice')
      showMenu()
      promptUser()
  }
}

function promptUser() {
  rl.question('\nEnter your choice (1-5): ', handleChoice)
}

// Start the CLI
showMenu()
promptUser()