/* Module Assignment Modal - Two-Step Wizard */
{showModuleAssignmentModal && (
  <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div className="bg-white rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-semibold">
          {assignmentStep === 1 ? 'Step 1: Select Modules' : 'Step 2: Select Objects'} - {selectedRoleForAssignment}
        </h3>
        <button onClick={() => {
          setShowModuleAssignmentModal(false)
          setAssignmentStep(1)
          setSelectedModulesForAssignment(new Set())
          setSelectedObjectsForAssignment(new Set())
        }}>
          <X className="h-5 w-5" />
        </button>
      </div>
      
      {/* Step 1: Module Selection */}
      {assignmentStep === 1 && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <p className="text-sm text-gray-600">
              Select modules to assign to this role.
            </p>
            <button
              onClick={selectAllAvailableModules}
              className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700"
            >
              Select All ({availableModulesForRole.length})
            </button>
          </div>
          
          <div className="max-h-60 overflow-y-auto border rounded-lg">
            {availableModulesForRole.length > 0 ? (
              <div className="divide-y">
                {availableModulesForRole.map(module => {
                  const moduleObjects = objectsByModule[module] || []
                  return (
                    <label key={module} className="flex items-center p-3 hover:bg-gray-50 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={selectedModulesForAssignment.has(module)}
                        onChange={() => toggleModuleForAssignment(module)}
                        className="w-4 h-4 text-blue-600 mr-3"
                      />
                      <div className="flex-1">
                        <div className="flex items-center space-x-2">
                          <span className="font-medium capitalize">{module}</span>
                          <span className="bg-gray-100 text-gray-700 text-xs px-2 py-1 rounded-full">
                            {moduleObjects.length} objects
                          </span>
                        </div>
                        <p className="text-sm text-gray-500">
                          {moduleObjects.map(obj => obj.object_name).slice(0, 3).join(', ')}
                          {moduleObjects.length > 3 && ` +${moduleObjects.length - 3} more`}
                        </p>
                      </div>
                    </label>
                  )
                })}
              </div>
            ) : (
              <div className="p-8 text-center text-gray-500">
                <Folder className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                <p>All modules are already assigned to this role</p>
              </div>
            )}
          </div>
          
          <div className="flex justify-between items-center pt-4 border-t">
            <span className="text-sm text-gray-600">
              {selectedModulesForAssignment.size} modules selected
            </span>
            <div className="flex space-x-3">
              <button
                onClick={() => {
                  setShowModuleAssignmentModal(false)
                  setSelectedModulesForAssignment(new Set())
                }}
                className="px-4 py-2 text-gray-600 border rounded-md hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={proceedToObjectSelection}
                disabled={selectedModulesForAssignment.size === 0}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center"
              >
                Next: Select Objects →
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Step 2: Object Selection */}
      {assignmentStep === 2 && (
        <div className="space-y-4">
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
            <p className="text-sm text-blue-800">
              <strong>Selected Modules:</strong> {Array.from(selectedModulesForAssignment).join(', ')}
            </p>
            <p className="text-sm text-blue-700 mt-1">
              {selectedObjectsForAssignment.size} of {Array.from(selectedModulesForAssignment).reduce((sum, m) => sum + (objectsByModule[m]?.length || 0), 0)} objects selected
            </p>
          </div>

          <div className="max-h-96 overflow-y-auto border rounded-lg">
            {Array.from(selectedModulesForAssignment).map(module => {
              const moduleObjects = objectsByModule[module] || []
              const allSelected = moduleObjects.every(obj => selectedObjectsForAssignment.has(obj.id))
              
              return (
                <div key={module} className="border-b last:border-b-0">
                  <div className="bg-gray-50 p-3 flex items-center justify-between">
                    <div className="flex items-center space-x-2">
                      <Folder className="w-4 h-4 text-blue-600" />
                      <span className="font-medium capitalize">{module} Module</span>
                      <span className="text-xs text-gray-600">
                        ({moduleObjects.filter(obj => selectedObjectsForAssignment.has(obj.id)).length}/{moduleObjects.length})
                      </span>
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => selectAllInModule(module)}
                        className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded hover:bg-green-200"
                      >
                        Select All
                      </button>
                      <button
                        onClick={() => deselectAllInModule(module)}
                        className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded hover:bg-gray-200"
                      >
                        Deselect All
                      </button>
                    </div>
                  </div>
                  
                  <div className="divide-y">
                    {moduleObjects.map(obj => (
                      <label key={obj.id} className="flex items-start p-3 hover:bg-gray-50 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={selectedObjectsForAssignment.has(obj.id)}
                          onChange={() => toggleObjectSelection(obj.id)}
                          className="w-4 h-4 text-blue-600 mt-1 mr-3"
                        />
                        <div className="flex-1">
                          <div className="flex items-center space-x-2">
                            <Shield className="w-4 h-4 text-green-600" />
                            <span className="font-mono text-sm font-semibold">{obj.object_name}</span>
                          </div>
                          <p className="text-sm text-gray-600 mt-1">{obj.description}</p>
                        </div>
                      </label>
                    ))}
                  </div>
                </div>
              )
            })}
          </div>

          <div className="flex justify-between items-center pt-4 border-t">
            <button
              onClick={() => {
                setAssignmentStep(1)
                setSelectedObjectsForAssignment(new Set())
              }}
              className="px-4 py-2 text-gray-600 border rounded-md hover:bg-gray-50 flex items-center"
            >
              ← Back to Modules
            </button>
            <div className="flex items-center space-x-3">
              <span className="text-sm text-gray-600">
                {selectedObjectsForAssignment.size} objects selected
              </span>
              <button
                onClick={assignSelectedObjects}
                disabled={selectedObjectsForAssignment.size === 0}
                className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
              >
                Assign {selectedObjectsForAssignment.size} Objects
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  </div>
)}
