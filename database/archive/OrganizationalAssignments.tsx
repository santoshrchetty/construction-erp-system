// SAP Organizational Assignment Interface - Using Existing Tables
// This replaces the current tab-based approach with proper hierarchy

export function OrganizationalAssignments() {
  const [selectedNode, setSelectedNode] = useState(null);
  const [orgData, setOrgData] = useState({
    companies: [],
    controllingAreas: [],
    plants: [],
    costCenters: [],
    departments: [],
    storageLocations: []
  });

  // Hierarchical structure using existing table relationships
  const buildOrgTree = () => {
    return orgData.companies.map(company => ({
      id: company.company_code,
      name: `${company.company_code} - ${company.company_name}`,
      type: 'company',
      data: company,
      children: [
        // Controlling Area (if assigned)
        ...(company.controlling_area_code ? [{
          id: `${company.company_code}-ca`,
          name: `Controlling: ${company.controlling_area_code}`,
          type: 'controlling_area',
          children: [
            // Cost Centers under this controlling area
            ...orgData.costCenters
              .filter(cc => cc.controlling_area_code === company.controlling_area_code)
              .map(cc => ({
                id: cc.cost_center_code,
                name: `${cc.cost_center_code} - ${cc.cost_center_name}`,
                type: 'cost_center',
                data: cc
              }))
          ]
        }] : []),
        
        // Plants under this company
        ...orgData.plants
          .filter(plant => plant.company_code === company.company_code)
          .map(plant => ({
            id: plant.plant_code,
            name: `${plant.plant_code} - ${plant.plant_name}`,
            type: 'plant',
            data: plant,
            children: [
              // Departments under this plant
              ...orgData.departments
                .filter(dept => dept.company_code === company.company_code)
                .map(dept => ({
                  id: dept.id,
                  name: `${dept.code} - ${dept.name}`,
                  type: 'department',
                  data: dept
                })),
              
              // Storage Locations under this plant
              ...orgData.storageLocations
                .filter(sl => sl.plant_code === plant.plant_code)
                .map(sl => ({
                  id: sl.storage_location_code,
                  name: `${sl.storage_location_code} - ${sl.storage_location_name}`,
                  type: 'storage_location',
                  data: sl
                }))
            ]
          }))
      ]
    }));
  };

  return (
    <div className="flex h-screen">
      {/* Left Panel: Object Creation */}
      <div className="w-1/3 bg-white border-r p-4">
        <h3 className="font-semibold mb-4">Create Objects</h3>
        <div className="space-y-2">
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            + Company Code
          </button>
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            + Controlling Area
          </button>
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            + Plant
          </button>
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            + Cost Center
          </button>
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            + Department
          </button>
          <button className="w-full text-left p-2 hover:bg-gray-100 rounded">
            + Storage Location
          </button>
        </div>
      </div>

      {/* Center Panel: Organizational Tree */}
      <div className="w-1/3 bg-gray-50 p-4">
        <h3 className="font-semibold mb-4">Organizational Structure</h3>
        <div className="space-y-2">
          {buildOrgTree().map(company => (
            <OrgTreeNode 
              key={company.id} 
              node={company} 
              level={0}
              onSelect={setSelectedNode}
            />
          ))}
        </div>
      </div>

      {/* Right Panel: Assignment Details */}
      <div className="w-1/3 bg-white border-l p-4">
        <h3 className="font-semibold mb-4">Assignment Details</h3>
        {selectedNode ? (
          <div>
            <h4 className="font-medium">{selectedNode.name}</h4>
            <p className="text-sm text-gray-600 mb-4">Type: {selectedNode.type}</p>
            
            {/* Assignment Actions */}
            <div className="space-y-2">
              {selectedNode.type === 'company' && (
                <select className="w-full p-2 border rounded">
                  <option>Assign Controlling Area...</option>
                  {orgData.controllingAreas.map(ca => (
                    <option key={ca.cocarea_code} value={ca.cocarea_code}>
                      {ca.cocarea_code} - {ca.cocarea_name}
                    </option>
                  ))}
                </select>
              )}
              
              {selectedNode.type === 'plant' && (
                <select className="w-full p-2 border rounded">
                  <option>Assign to Company...</option>
                  {orgData.companies.map(company => (
                    <option key={company.company_code} value={company.company_code}>
                      {company.company_code} - {company.company_name}
                    </option>
                  ))}
                </select>
              )}
            </div>
          </div>
        ) : (
          <p className="text-gray-500">Select an object to view details</p>
        )}
      </div>
    </div>
  );
}

// Tree Node Component
function OrgTreeNode({ node, level, onSelect }) {
  const [expanded, setExpanded] = useState(true);
  
  return (
    <div>
      <div 
        className={`flex items-center p-2 hover:bg-blue-50 cursor-pointer rounded`}
        style={{ paddingLeft: `${level * 20 + 8}px` }}
        onClick={() => onSelect(node)}
      >
        {node.children?.length > 0 && (
          <button 
            onClick={(e) => {
              e.stopPropagation();
              setExpanded(!expanded);
            }}
            className="mr-2 text-gray-500"
          >
            {expanded ? '▼' : '▶'}
          </button>
        )}
        <span className="text-sm">{node.name}</span>
      </div>
      
      {expanded && node.children?.map(child => (
        <OrgTreeNode 
          key={child.id} 
          node={child} 
          level={level + 1}
          onSelect={onSelect}
        />
      ))}
    </div>
  );
}