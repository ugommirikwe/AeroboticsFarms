import CoreData
import DomainModel
import ApplicationError

open class PersistentContainer: NSPersistentContainer {}

final public class FarmDataSourceLocalWithCoreData: FarmDataSourceLocalProtocol {
    public static let shared = FarmDataSourceLocalWithCoreData()
    
    let container: PersistentContainer
    
    init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource:"AeroboticsFarms", withExtension: "momd") else {
            fatalError("Bundle not found")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to initialize NSManagedObjectModel for model: \(modelURL)")
        }
        
        container = PersistentContainer(name:"AeroboticsFarms", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let nsError = error as NSError? {
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    public func getFarm(
        id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Farm?, DataSourceError>) -> Void
    ) {
        let fetchRequest: NSFetchRequest<Farm> = Farm.farmFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let viewContext = container.newBackgroundContext()
        
        viewContext.perform {
            do {
                let farms = try viewContext.fetch(fetchRequest)
                guard let farm = farms.first else {
                    completionHandler(.success(nil))
                    return
                }
                
                let result = DomainModel.Farm(
                    id: farm.id,
                    name: farm.name,
                    clientId: farm.clientId
                )
                
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(.dbAccessError(description: error.localizedDescription)))
            }
        }
    }
    
    public func getFarms(
        ids: [Int] = [],
        clientIds: [Int] = [],
        limit: Int? = nil,
        offset: Int? = nil,
        _ completionHandler: @escaping (Result<[DomainModel.Farm], DataSourceError>) -> Void
    ) {
        let fetchRequest: NSFetchRequest<Farm> = Farm.farmFetchRequest()
        var allPredicates = [NSPredicate]()
        
        if !ids.isEmpty {
            allPredicates.append(NSPredicate(format: "id IN %@", ids.map { Int16($0) }))
        }
        
        if !clientIds.isEmpty {
            allPredicates.append(NSPredicate(format: "clientId in %@", clientIds))
        }
        
        if !allPredicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        }
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        if let offset = offset {        
            fetchRequest.fetchOffset = offset
        }
        
        let viewContext = container.newBackgroundContext()
        viewContext.perform {
            do {
                let farms = try viewContext.fetch(fetchRequest).compactMap {
                    DomainModel.Farm(id: $0.id, name: $0.name, clientId: $0.clientId)
                }
                    
                completionHandler(.success(farms))
            } catch {
                completionHandler(.failure(.dbAccessError(description: error.localizedDescription)))
            }
        }
    }
    
    public func saveOrUpdateFarms(
        _ farms: [DomainModel.Farm],
        _ completionHandler: @escaping (Result<Void, DataSourceError>) -> Void
    ) {
        guard !farms.isEmpty else {
            completionHandler(.success(()))
            return
        }

        let viewContext = container.newBackgroundContext()
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        viewContext.automaticallyMergesChangesFromParent = true
        
        for farm in farms {
            let newFarm = Farm(context: viewContext)
            newFarm.name = farm.name
            newFarm.id = farm.id
            newFarm.clientId = farm.clientId
            
            viewContext.perform {
                do {
                    try viewContext.save()
                    completionHandler(.success(()))
                } catch {
                    completionHandler(.failure(.dbAccessError(description: error.localizedDescription)))
                }
            }
        }
    }
    
    public func getOrchard(
        id: Int,
        _ completionHandler: @escaping (Result<DomainModel.Orchard?, DataSourceError>) -> Void
    ) {
        let fetchRequest: NSFetchRequest<Orchard> = Orchard.orchardFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", Int16(id))
        
        let viewContext = container.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.perform {
            do {
                let orchards = try viewContext.fetch(fetchRequest)
                guard let orchard = orchards.first else {
                    completionHandler(.success(nil))
                    return
                }
                
                let result = DomainModel.Orchard(
                    id: orchard.id,
                    hectares: orchard.hectares,
                    name: orchard.name,
                    farmId: orchard.farmId,
                    clientId: orchard.clientId,
                    polygon: orchard.polygon,
                    cropType: orchard.cropType
                )
                
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(.dbAccessError(description: error.localizedDescription)))
            }
        }
    }
    
    public func getOrchards(
        ids: [Int] = [],
        clientIds: [Int] = [],
        farmIds: [Int] = [],
        limit: Int? = nil,
        offset: Int? = nil,
        _ completionHandler: @escaping (Result<[DomainModel.Orchard], DataSourceError>) -> Void
    ) {
        let fetchRequest: NSFetchRequest<Orchard> = Orchard.orchardFetchRequest()
        var allPredicates = [NSPredicate]()
        
        if !ids.isEmpty {
            allPredicates.append(NSPredicate(format: "id IN %@", ids.map { Int16($0) }))
        }
        
        if !clientIds.isEmpty {
            allPredicates.append(NSPredicate(format: "clientId in %@", clientIds.map { Int16($0) }))
        }
        
        if !farmIds.isEmpty {
            allPredicates.append(NSPredicate(format: "farmId IN %@", farmIds.map { Int16($0) }))
        }
        
        if !allPredicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        }
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        if let offset = offset {        
            fetchRequest.fetchOffset = offset
        }
        
        let viewContext = container.newBackgroundContext()
        viewContext.perform {
            do {
                let orchards = try viewContext.fetch(fetchRequest).compactMap {
                    DomainModel.Orchard(
                        id: $0.id,
                        hectares: $0.hectares,
                        name: $0.name,
                        farmId: $0.farmId,
                        clientId: $0.clientId,
                        polygon: $0.polygon,
                        cropType: $0.cropType
                    )
                }
                
                completionHandler(.success(orchards))
            } catch {
                completionHandler(.failure(.dbAccessError(description: error.localizedDescription)))
            }
        }
    }
    
    public func saveOrUpdateOrchards(
        _ orchards: [DomainModel.Orchard],
        _ completionHandler: @escaping (Result<Void, DataSourceError>) -> Void
    ) {
        guard !orchards.isEmpty else {
            completionHandler(.success(()))
            return
        }
        
        let viewContext = container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        for orchard in orchards {
            let newOrchard = Orchard(context: viewContext)
            newOrchard.id = orchard.id
            newOrchard.hectares = orchard.hectares
            newOrchard.name = orchard.name
            newOrchard.farmId = orchard.farmId
            newOrchard.clientId = orchard.clientId
            newOrchard.polygon = orchard.polygon
            newOrchard.cropType = orchard.cropType
            
            viewContext.perform {
                do {
                    try viewContext.save()
                    completionHandler(.success(()))
                } catch {
                    completionHandler(.failure(.dbAccessError(description: error.localizedDescription)))
                }
            }
        }
    }
}
