//
//  NSManagedObjectContext+Querying.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreData


// MARK: - NSManagedObjectContext

extension NSManagedObjectContext: FetchableSource, QueryableSource {
    
    // MARK: FetchableSource
    
    @nonobjc
    public func fetchExisting<T: NSManagedObject>(_ object: T) -> T? {
        
        if object.objectID.isTemporaryID {
            
            do {
                
                try withExtendedLifetime(self) { (context: NSManagedObjectContext) -> Void in
                    
                    try context.obtainPermanentIDs(for: [object])
                }
            }
            catch {
                
                CoreStore.log(
                    CoreStoreError(error),
                    "Failed to obtain permanent ID for object."
                )
                return nil
            }
        }
        do {
            
            let existingObject = try self.existingObject(with: object.objectID)
            return (existingObject as! T)
        }
        catch {
            
            CoreStore.log(
                CoreStoreError(error),
                "Failed to load existing \(cs_typeName(object)) in context."
            )
            return nil
        }
    }
    
    @nonobjc
    public func fetchExisting<T: NSManagedObject>(_ objectID: NSManagedObjectID) -> T? {
        
        do {
            
            return (try self.existingObject(with: objectID) as! T)
        }
        catch _ {
            
            return nil
        }
    }
    
    @nonobjc
    public func fetchExisting<T: NSManagedObject, S: Sequence>(_ objects: S) -> [T] where S.Iterator.Element == T {
        
        return objects.flatMap { (try? self.existingObject(with: $0.objectID)) as? T }
    }
    
    @nonobjc
    public func fetchExisting<T: NSManagedObject, S: Sequence>(_ objectIDs: S) -> [T] where S.Iterator.Element == NSManagedObjectID {
        
        return objectIDs.flatMap { (try? self.existingObject(with: $0)) as? T }
    }
    
    @nonobjc
    public func fetchOne<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> T? {
        
        
        return self.fetchOne(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchOne<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> T? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchOne(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    public func fetchAll<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> [T]? {
        
        return self.fetchAll(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchAll<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchAll(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    public func fetchCount<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> Int? {
    
        return self.fetchCount(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchCount<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchCount(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    public func fetchObjectID<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> NSManagedObjectID? {
        
        return self.fetchObjectID(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchObjectID<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectID(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    public func fetchObjectIDs<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        return self.fetchObjectIDs(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchObjectIDs<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectIDs(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    internal func fetchObjectIDs(_ fetchRequest: NSFetchRequest<NSManagedObjectID>) -> [NSManagedObjectID]? {
        
        var fetchResults: [NSManagedObjectID]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        return fetchResults
    }
    
    
    // MARK: QueryableSource
    
    @nonobjc
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(_ from: From<T>, _ selectClause: Select<U>, _ queryClauses: QueryClause...) -> U? {
        
        return self.queryValue(from, selectClause, queryClauses)
    }
    
    @nonobjc
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(_ from: From<T>, _ selectClause: Select<U>, _ queryClauses: [QueryClause]) -> U? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        let selectTerms = selectClause.selectTerms
        selectTerms.applyToFetchRequest(fetchRequest, owner: selectClause)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryValue(selectTerms, fetchRequest: fetchRequest)
    }
    
    @nonobjc
    public func queryAttributes<T: NSManagedObject>(_ from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[String: Any]]? {
        
        return self.queryAttributes(from, selectClause, queryClauses)
    }
    
    @nonobjc
    public func queryAttributes<T: NSManagedObject>(_ from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[String: Any]]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.selectTerms.applyToFetchRequest(fetchRequest, owner: selectClause)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryAttributes(fetchRequest)
    }
    
    
    // MARK: FetchableSource, QueryableSource
    
    @nonobjc
    public func internalContext() -> NSManagedObjectContext {
        
        return self
    }
}


// MARK: - NSManagedObjectContext (Internal)

internal extension NSManagedObjectContext {
    
    // MARK: Fetching
    
    @nonobjc
    internal func fetchOne<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> T? {
        
        var fetchResults: [T]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        return fetchResults?.first
    }
    
    @nonobjc
    internal func fetchAll<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> [T]? {
        
        var fetchResults: [T]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        return fetchResults
    }
    
    @nonobjc
    internal func fetchCount(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Int? {
        
        var count = 0
        var countError: Error?
        self.performAndWait {
            
            do {
                
                count = try self.count(for: fetchRequest)
            }
            catch {
                
                countError = error
            }
        }
        if count == NSNotFound {
            
            CoreStore.log(
                CoreStoreError(countError),
                "Failed executing count request."
            )
            return nil
        }
        return count
    }
    
    @nonobjc
    internal func fetchObjectID(_ fetchRequest: NSFetchRequest<NSManagedObjectID>) -> NSManagedObjectID? {
        
        var fetchResults: [NSManagedObjectID]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        return fetchResults?.first
    }
    
    
    // MARK: Querying
    
    @nonobjc
    internal func queryValue<U: SelectValueResultType>(_ selectTerms: [SelectTerm], fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> U? {
        
        var fetchResults: [Any]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            if let rawResult = fetchResults.first as? NSDictionary,
                let rawObject = rawResult[selectTerms.keyPathForFirstSelectTerm()] {
                
                return Select<U>.ReturnType.fromResultObject(rawObject)
            }
            return nil
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
    
    @nonobjc
    internal func queryValue(_ selectTerms: [SelectTerm], fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Any? {
        
        var fetchResults: [Any]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            if let rawResult = fetchResults.first as? NSDictionary,
                let rawObject = rawResult[selectTerms.keyPathForFirstSelectTerm()] {
                
                return rawObject
            }
            return nil
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
    
    @nonobjc
    internal func queryAttributes(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [[String: Any]]? {
        
        var fetchResults: [Any]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            return Select<NSDictionary>.ReturnType.fromResultObjects(fetchResults)
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
    
    
    // MARK: Deleting
    
    @nonobjc
    internal func deleteAll<T: NSManagedObject>(_ from: From<T>, _ deleteClauses: DeleteClause...) -> Int? {
        
        return self.deleteAll(from, deleteClauses)
    }
    
    @nonobjc
    internal func deleteAll<T: NSManagedObject>(_ from: From<T>, _ deleteClauses: [DeleteClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        deleteClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.deleteAll(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    internal func deleteAll<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> Int? {
        
        var numberOfDeletedObjects: Int?
        var fetchError: Error?
        self.performAndWait {
            
            autoreleasepool {
                
                do {
                    
                    let fetchResults = try self.fetch(fetchRequest)
                    for object in fetchResults {
                        
                        self.delete(object)
                    }
                    numberOfDeletedObjects = fetchResults.count
                }
                catch {
                    
                    fetchError = error
                }
            }
        }
        if numberOfDeletedObjects == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        return numberOfDeletedObjects
    }
}
